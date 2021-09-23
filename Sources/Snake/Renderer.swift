import MetalKit
import RenderSetup
import Math
import ThreadGrid


class Renderer: NSObject, MTKViewDelegate {
        
    let renderPacket: RenderPacket 
    
    // Compute
    let clearTextureState: MTLComputePipelineState
    let advectState: MTLComputePipelineState
    let captureState: MTLComputePipelineState
    let copyState: MTLComputePipelineState
    let fillTextureState: MTLComputePipelineState
    let setVelocityState: MTLComputePipelineState
    
    // Render
    let pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    
    // Model
    var fridge: SnakeFridge
    var track: Track
    var rotateXY: SIMD2<Float>
    var scene: Scene
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        metalView.framebufferOnly = false
        metalView.depthStencilPixelFormat = .depth32Float
        metalView.device = renderPacket.device
        
        
        var function = renderPacket.library.makeFunction(name: "fillSnakeTextureToDark")!
        clearTextureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "unitAdvectVelocitySnake")!
        advectState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "fillSnakeTexture")!
        fillTextureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "setHeadVelocity")!
        setVelocityState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "captureSnake")!
        captureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "copySnake")!
        copyState = try! renderPacket.device.makeComputePipelineState(function: function)
        
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
        
        fridge = SnakeFridge(packet: renderPacket)
        scene = Scene(renderPacket: renderPacket)
        scene.camera.aspect = Float(metalView.bounds.width)/Float(metalView.bounds.height)
        rotateXY = .zero
        track = Track()
        super.init()
    }
    
    func compute() {
        print("compute")
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!    
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!


        var width = advectState.threadExecutionWidth
        var height = advectState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(advectState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0) // From
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1) // To
        commandEncoder.setBuffer(fridge.infobuffer.buffer, offset: 0, index: 2)
        commandEncoder.setBuffer(fridge.debug.buffer, offset: 0, index: 5)
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        width = copyState.threadExecutionWidth
        height = copyState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(copyState)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0) // source
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 1) // target
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        width = captureState.threadExecutionWidth
        height = captureState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(captureState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: fridge.white.buffer, 
                         sourceOffset: 0, 
                         to: fridge.black.buffer, 
                         destinationOffset: 0, 
                         size: fridge.white.biteSize)
        blitEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        scene.white = fridge.white
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

// Touch API
extension Renderer {
    func mouseDown(at point: CGPoint) {
        compute()
    }
    func mouseDrug(at point: CGPoint) {
        guard let dif = track.getDiff(touch: point.simd2float) else { return }
        rotateXY += dif / 100
        scene.fridge.body.rotation = [-rotateXY.y, rotateXY.x, 0]
    }
    func mouseUp(at point: CGPoint) {
        track.touchUp()
    }
}
