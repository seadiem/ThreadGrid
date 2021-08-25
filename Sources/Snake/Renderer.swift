import MetalKit
import RenderSetup
import Math


class Renderer: NSObject, MTKViewDelegate {
        
    let renderPacket: RenderPacket
    let mesh: MTKMesh    
    let pipelineState: MTLRenderPipelineState!
    let depthStencilState: MTLDepthStencilState
    
    // Model
    var track = Track()
    var rotateXY: SIMD2<Float>
    var scene: Scene
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        metalView.framebufferOnly = false
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.device = renderPacket.device
        
        let allocator = MTKMeshBufferAllocator(device: renderPacket.device)
        let iomesh = MDLMesh(boxWithExtent: [5, 5, 5],segments: [1, 1, 1],
                           inwardNormals: false, geometryType: .triangles,
                           allocator: allocator)
        iomesh.addNormals(withAttributeNamed: MDLVertexAttributeNormal, creaseThreshold: 1)
        iomesh.vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor
        mesh = try! MTKMesh(mesh: iomesh, device: renderPacket.device)
        rotateXY = .zero
        
        let vertexfunction = renderPacket.library.makeFunction(name: "vertexMainRazewareInstancing")!
        let fragmentfunction = renderPacket.library.makeFunction(name: "fragmentMainRazeware")!
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexfunction
        pipelineDescriptor.fragmentFunction = fragmentfunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(MDLVertexDescriptor.defaultVertexDescriptor)
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        pipelineState = try! renderPacket.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        
  
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        depthStencilState = renderPacket.device.makeDepthStencilState(descriptor: descriptor)!
        
        scene = Scene(renderPacket: renderPacket)
        scene.camera.aspect = Float(metalView.bounds.width)/Float(metalView.bounds.height)
        super.init()
    }
    
    func draw(in view: MTKView) {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let descriptor = view.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        scene.draw(into: renderEncoder)
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
        scene.camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
    }
}

// API
extension Renderer {
    func mouseDown(at point: CGPoint) {}
    func mouseDrug(at point: CGPoint) {
        guard let dif = track.getDiff(touch: point.simd2float) else { return }
        rotateXY += dif / 100
        scene.fridge.body.rotation = [-rotateXY.y, rotateXY.x, 0]
    }
    func mouseUp(at point: CGPoint) {
        track.touchUp()
    }
}
