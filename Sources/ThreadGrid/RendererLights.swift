import MetalKit
import MetalPerformanceShaders

class RendererLights: NSObject {
    let insectState: MTLComputePipelineState
    let firstState: MTLComputePipelineState
    let secondState: MTLComputePipelineState
    let renderPacket: RenderPacket
    var buffer: RowBuffer
    var point: Butterfly
    var insects: Butterflies
    let texture: MTLTexture
    let middleTexture: MTLTexture
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        buffer = RowBuffer(packet: renderPacket)
        let position: SIMD2<Float> = [100, 50]
        point = Butterfly(id: 0, position: position, velocity: .zero)
        insects = Butterflies(packet: renderPacket)
        
        metalView.framebufferOnly = false
        
        let library = renderPacket.library
        let zeroPass = library.makeFunction(name: "insectPass")!
        let firstPass = library.makeFunction(name: "firstPass")!
        let secondPass = library.makeFunction(name: "secondPassLight")!
        insectState = try! renderPacket.device.makeComputePipelineState(function: zeroPass)
        firstState = try! renderPacket.device.makeComputePipelineState(function: firstPass)
        secondState = try! renderPacket.device.makeComputePipelineState(function: secondPass)
        
        texture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        middleTexture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        
        super.init()
    }
    
    static func makeTexture(view: MTKView, device: MTLDevice) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, 
                                                                  width: Int(view.bounds.width), 
                                                                  height: Int(view.bounds.height), 
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
    
}

extension RendererLights: MTKViewDelegate {
    func draw(in view: MTKView) {
        
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        // first pass
        commandEncoder.setComputePipelineState(firstState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        let width = firstState.threadExecutionWidth
        let height = firstState.maxTotalThreadsPerThreadgroup / width
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // insect pass
        commandEncoder.setComputePipelineState(insectState)
        threadsPerGroup = MTLSizeMake(1, 1, 1)
        threadsPerGrid = MTLSizeMake(insects.count, 1, 1)
        let points = [point]
        let length = MemoryLayout<Butterfly>.stride * points.count
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // light pass
        commandEncoder.setComputePipelineState(secondState)
        commandEncoder.setTexture(middleTexture, index: 0)
        threadsPerGroup = MTLSizeMake(1, 1, 1)
        threadsPerGrid = MTLSizeMake(buffer.width, buffer.height, 1)
        commandEncoder.setBuffer(buffer.buffer, offset: 0, index: 0)
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 2)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        // blit encoder
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {return }
        let origin = MTLOriginMake(0, 0, 0)
        let size = MTLSizeMake(drawable.texture.width, drawable.texture.height, 1)
        blitEncoder.copy(from: middleTexture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: origin, sourceSize: size,
                         to: drawable.texture, destinationSlice: 0,
                         destinationLevel: 0, destinationOrigin: origin)
        blitEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
