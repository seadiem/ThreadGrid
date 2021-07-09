import MetalKit

class Renderer: NSObject {
    var insectState: MTLComputePipelineState?
    var firstState: MTLComputePipelineState?
    var secondState: MTLComputePipelineState?
    let renderPacket: RenderPacket
    var buffer: RowBuffer
    var point: SIMD2<Float>
    var insects: Butterflies
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        buffer = RowBuffer(packet: renderPacket)
        point = .zero
        insects = Butterflies(packet: renderPacket)
        super.init()
        initializeMetal(metalView: metalView)
    }
        
    func initializeMetal(metalView: MTKView) {
        metalView.framebufferOnly = false
        
        let library = renderPacket.library
        let zeroPass = library.makeFunction(name: "insectPass")!
        let firstPass = library.makeFunction(name: "firstPass")!
        let secondPass = library.makeFunction(name: "secondPassLight")!
        insectState = try! renderPacket.device.makeComputePipelineState(function: zeroPass)
        firstState = try! renderPacket.device.makeComputePipelineState(function: firstPass)
        secondState = try! renderPacket.device.makeComputePipelineState(function: secondPass)
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
}

var drawcount = 0

extension Renderer: MTKViewDelegate {
    func draw(in view: MTKView) {
        
        
        drawcount += 1
   
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
        let length = MemoryLayout<SIMD2<Float>>.stride * points.count
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // light pass
        commandEncoder.setComputePipelineState(secondState!)
        commandEncoder.setTexture(drawable.texture, index: 0)
        threadsPerGroup = MTLSizeMake(1, 1, 1)
        threadsPerGrid = MTLSizeMake(buffer.width, buffer.height, 1)
        commandEncoder.setBuffer(buffer.buffer, offset: 0, index: 0)
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.setBuffer(insects.particleBuffer, offset: 0, index: 2)
        
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
