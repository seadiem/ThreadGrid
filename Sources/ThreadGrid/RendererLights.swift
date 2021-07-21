import MetalKit
import MetalPerformanceShaders

public class RendererLights: NSObject {

    var point: Butterfly
    var insects: Butterflies
    var buffer: RowBuffer
    
    let renderPacket: RenderPacket
    let insectState: MTLComputePipelineState
    let firstState: MTLComputePipelineState
    let secondState: MTLComputePipelineState
    var composeState: MTLComputePipelineState?
    var middleTexture: MTLTexture
    var effectedTexture1: MTLTexture
    var effectedTexture2: MTLTexture
    var composedTexture: MTLTexture
    
    public init(metalView: MTKView) {
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
        let composePass = library.makeFunction(name: "copyTextures")!
        insectState = try! renderPacket.device.makeComputePipelineState(function: zeroPass)
        firstState = try! renderPacket.device.makeComputePipelineState(function: firstPass)
        secondState = try! renderPacket.device.makeComputePipelineState(function: secondPass)
        composeState = try! renderPacket.device.makeComputePipelineState(function: composePass)
        
        middleTexture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        effectedTexture1 = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        effectedTexture2 = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        composedTexture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        
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
    public func draw(in view: MTKView) {
        
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
        let w = insectState.threadExecutionWidth
        let threadsPerThreadgroup = MTLSizeMake(w, 1, 1) 
        threadsPerGrid = MTLSizeMake(insects.count, 1, 1)
        let points = [point]
        let length = MemoryLayout<Butterfly>.stride * points.count
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        // light pass
        commandEncoder.setComputePipelineState(secondState)
        commandEncoder.setTexture(middleTexture, index: 0)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(buffer.width, buffer.height, 1)
        commandEncoder.setBuffer(buffer.buffer, offset: 0, index: 0)
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 2)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        // effects
        let shader = MPSImageSobel(device: renderPacket.device)
        shader.encode(commandBuffer: commandBuffer, sourceTexture: middleTexture, destinationTexture: effectedTexture1)
        let blur = MPSImageGaussianBlur(device: renderPacket.device, sigma: 10)
        blur.encode(commandBuffer: commandBuffer, sourceTexture: middleTexture, destinationTexture: effectedTexture2)
        
        // compose pass
        guard let encoderSecond = commandBuffer.makeComputeCommandEncoder() else { return }
        encoderSecond.setComputePipelineState(composeState!)
        encoderSecond.setTexture(composedTexture, index: 0)
        encoderSecond.setTexture(effectedTexture2, index: 1)
        encoderSecond.setTexture(effectedTexture1, index: 2)
        encoderSecond.setBytes(points, length: length, index: 1)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        encoderSecond.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        encoderSecond.endEncoding()
        
        // blit encoder
//        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {return }
//        let origin = MTLOriginMake(0, 0, 0)
//        let size = MTLSizeMake(drawable.texture.width, drawable.texture.height, 1)
//        blitEncoder.copy(from: composedTexture, sourceSlice: 0, sourceLevel: 0,
//                         sourceOrigin: origin, sourceSize: size,
//                         to: drawable.texture, destinationSlice: 0,
//                         destinationLevel: 0, destinationOrigin: origin)
//        blitEncoder.endEncoding()
        
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

public extension RendererLights {
    func set(point: SIMD2<Float>) {
        self.point.position = point
    }
    func select(at point: SIMD2<Float>) {
        if let last = insects.select(at: point, current: self.point) {
            self.point = last
        }
    }
}
