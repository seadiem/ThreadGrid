import MetalKit
import RenderSetup
import Math

class Renderer: NSObject, MTKViewDelegate {
        
    let renderPacket: RenderPacket
    let mesh: MTKMesh
    var rotateXY: SIMD2<Float>
    
    let pipelineState: MTLRenderPipelineState!
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        metalView.framebufferOnly = false
        
        let allocator = MTKMeshBufferAllocator(device: renderPacket.device)
        let iomesh = MDLMesh(boxWithExtent: [5, 5, 2],segments: [1, 1, 1],
                           inwardNormals: false, geometryType: .triangles,
                           allocator: allocator)
        mesh = try! MTKMesh(mesh: iomesh, device: renderPacket.device)
        let z = mesh.vertexDescriptor
        print("z: \(z)")
        rotateXY = .zero
        
        let vertexfunction = renderPacket.library.makeFunction(name: "snakeVertex")!
        let fragmentfunction = renderPacket.library.makeFunction(name: "snakeFragment")!
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexfunction
        pipelineDescriptor.fragmentFunction = fragmentfunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineState = try! renderPacket.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        super.init()
    }
    func rotate(xy: SIMD2<Float>) { rotateXY = xy }
    func draw(in view: MTKView) {
        print(rotateXY)
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let descriptor = view.currentRenderPassDescriptor!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        let size = view.bounds.size
        let matricies = Matricies(screen: [Float(size.width), Float(size.height)], 
                          position: [0, 0, 0], 
                          // rotation: [0, -rotateXY.x, rotateXY.y],
                          rotation: [rotateXY.y, -rotateXY.x, 0],
                          moveCamera: [0, 0, -10], 
                          localTransform: ModelTransformation())
        
        var matrixbuffer = [simd_float4x4]()
        matrixbuffer.append(matricies.projectionMatrix)
        matrixbuffer.append(matricies.viewMatrix)
        matrixbuffer.append(matricies.modelMatrix)
        renderEncoder.setVertexBytes(matrixbuffer, length: matrixbuffer.count * MemoryLayout<simd_float4x4>.stride, index: 1)
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
