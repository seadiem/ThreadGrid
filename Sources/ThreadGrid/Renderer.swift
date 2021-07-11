import MetalKit
import MetalPerformanceShaders

class Renderer: NSObject {
    var insectState: MTLComputePipelineState?
    var firstState: MTLComputePipelineState?
    var secondState: MTLComputePipelineState?
    var thirdState: MTLComputePipelineState?
    let renderPacket: RenderPacket
    var buffer: RowBuffer
    var point: Butterfly
    var insects: Butterflies
    var texture: MTLTexture!
    var middleTexture: MTLTexture! 
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        buffer = RowBuffer(packet: renderPacket)
        let position: SIMD2<Float> = [100, 50]
        point = Butterfly(id: 0, position: position, velocity: .zero)
        insects = Butterflies(packet: renderPacket)
        super.init()
        initializeMetal(metalView: metalView)
        texture = makeTexture(view: metalView)
        middleTexture = makeTexture(view: metalView)
    }
        
    func initializeMetal(metalView: MTKView) {
        metalView.framebufferOnly = false
        
        let library = renderPacket.library
        let zeroPass = library.makeFunction(name: "insectPass")!
        let firstPass = library.makeFunction(name: "firstPass")!
        let secondPass = library.makeFunction(name: "secondPassLight")!
        let thirdPass = library.makeFunction(name: "copyTextures")!
        insectState = try! renderPacket.device.makeComputePipelineState(function: zeroPass)
        firstState = try! renderPacket.device.makeComputePipelineState(function: firstPass)
        secondState = try! renderPacket.device.makeComputePipelineState(function: secondPass)
        thirdState = try! renderPacket.device.makeComputePipelineState(function: thirdPass)
    }
    func makeTexture(view: MTKView) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, 
                                                                  width: Int(view.bounds.width), 
                                                                  height: Int(view.bounds.height), 
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return renderPacket.device.makeTexture(descriptor: descriptor)
        
    }
    func part() {
        buffer.fullPartition()
    }
    func random() {
        buffer = RowBuffer(packet: renderPacket)
    }
    func rotate() {
        buffer.fullRotate()
    }
    func shuffle() {
        buffer.fullShuffle()
    }
    func sort() {
        buffer.fullSort()
    }
    func select(at point: SIMD2<Float>) {
        if let last = insects.select(at: point, current: self.point) {
            self.point = last
        }
    }
}

extension Renderer: MTKViewDelegate {
    func draw(in view: MTKView) {
        
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        // first pass
        commandEncoder.setComputePipelineState(firstState!)
        commandEncoder.setTexture(drawable.texture, index: 0)
        let width = firstState!.threadExecutionWidth
        let height = firstState!.maxTotalThreadsPerThreadgroup / width
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // insect pass
        commandEncoder.setComputePipelineState(insectState!)
        threadsPerGroup = MTLSizeMake(1, 1, 1)
        threadsPerGrid = MTLSizeMake(insects.count, 1, 1)
        let points = [point]
        let length = MemoryLayout<Butterfly>.stride * points.count
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // light pass
        commandEncoder.setComputePipelineState(secondState!)
        commandEncoder.setTexture(middleTexture, index: 0)
        threadsPerGroup = MTLSizeMake(1, 1, 1)
        threadsPerGrid = MTLSizeMake(buffer.width, buffer.height, 1)
        commandEncoder.setBuffer(buffer.buffer, offset: 0, index: 0)
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 2)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        // effects
        let blur = MPSImageGaussianBlur(device: renderPacket.device, sigma: 10)
        blur.encode(commandBuffer: commandBuffer, sourceTexture: middleTexture, destinationTexture: texture)

        
        guard let encoderSecond = commandBuffer.makeComputeCommandEncoder() else { return }
        
        // compose pass
        encoderSecond.setComputePipelineState(thirdState!)
        encoderSecond.setTexture(drawable.texture, index: 0)
        encoderSecond.setTexture(texture, index: 1)
        encoderSecond.setTexture(middleTexture, index: 2)
        encoderSecond.setBytes(points, length: length, index: 1)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        encoderSecond.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        encoderSecond.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func allocator(kernel: MPSKernel, buffer: MTLCommandBuffer, texture: MTLTexture) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: texture.pixelFormat,
                                                                  width: texture.width,
                                                                  height: texture.height,
                                                                  mipmapped: false)
        return buffer.device.makeTexture(descriptor: descriptor)!
    }
}
