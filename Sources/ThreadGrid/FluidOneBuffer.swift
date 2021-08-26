import RenderSetup

struct FluidFridgeOne {
    let width = 18
    let height = 18
    var black: ThreadGridBuffer<FluidCell>
    init(packet: RenderPacket) {
        black = ThreadGridBuffer<FluidCell>(device: packet.device, width: width, height: height)
        touchSpot()
    }
    mutating func touchSpot() {
        black.columns[1][1].density = 1.0
        black.fillBuffer()
    }
    mutating func renderBlackWhite() {
        print("-")
        black.unbind()
        black.render()
    }
}

import MetalKit
class AdvectRendererOne: NSObject, MTKViewDelegate  {
    
    let renderPacket: RenderPacket
    var fridge: FluidFridgeOne
    var texture: MTLTexture
    
    let zeroState: MTLComputePipelineState
    let boundState: MTLComputePipelineState
    let firstState: MTLComputePipelineState
    let lastState: MTLComputePipelineState
    
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        fridge = FluidFridgeOne(packet: renderPacket)
        texture = AdvectRenderer.makeTexture(view: metalView, 
                                             size: [fridge.width, fridge.height], 
                                             device: renderPacket.device, scale: 6)!
        metalView.framebufferOnly = false
        var function = renderPacket.library.makeFunction(name: "fillTextureToDark")!
        zeroState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "advectK1_3")!
        firstState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "fillTexture")!
        lastState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "field")!
        boundState = try! renderPacket.device.makeComputePipelineState(function: function)
        super.init()
    }
    static func makeTexture(view: MTKView, size: SIMD2<Int>, device: MTLDevice, scale: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, 
                                                                  width: size.x * scale, 
                                                                  height: size.y * scale, 
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
    func pass(forceX: Float, forceY: Float) {
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder()
              else { return }
        let width = boundState.threadExecutionWidth
        let height = boundState.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.setComputePipelineState(boundState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        
        let force: SIMD2<Float> = [forceX, forceY]
        let forcePass = [force]
        print("forcePass: \(forcePass)")
        let length = MemoryLayout<SIMD2<Float>>.stride * 1
        commandEncoder.setBytes(forcePass, length: length, index: 1)
        
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
 //       fridge.renderBlackWhite()
        
    }
    func set(point: SIMD2<Float>) {}
    public func draw(in view: MTKView) {
        
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        
        
        let width = firstState.threadExecutionWidth
        let height = firstState.maxTotalThreadsPerThreadgroup / width
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        commandEncoder.setComputePipelineState(zeroState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(firstState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(lastState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        commandEncoder.setTexture(texture, index: 0)
        threadsPerGrid = MTLSizeMake(texture.width * 2, texture.height * 2, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {return }
        let origin = MTLOriginMake(0, 0, 0)
        let size = MTLSizeMake(texture.width, texture.height, 1)
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: origin, sourceSize: size,
                         to: drawable.texture, destinationSlice: 0,
                         destinationLevel: 0, destinationOrigin: origin)
        blitEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
      
//        fridge.renderBlackWhite()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
