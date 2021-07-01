import MetalKit

class Renderer: NSObject {
    
    var firstState: MTLComputePipelineState?
    var secondState: MTLComputePipelineState?
    let renderPacket: RenderPacket
    var buffer: Buffer
    var needrandom = true
    
    init(metalView: MTKView) {
        renderPacket = RenderPacket()
        buffer = Buffer(packet: renderPacket)
        super.init()
        initializeMetal(metalView: metalView)
    }
    
    deinit {
        print("render deinit")
    }
    
    func initializeMetal(metalView: MTKView) {
        metalView.framebufferOnly = false
        
        let library = renderPacket.library
        let firstPass = library.makeFunction(name: "firstPass")!
        let secondPass = library.makeFunction(name: "secondPass")!
        firstState = try! renderPacket.device.makeComputePipelineState(function: firstPass)
        secondState = try! renderPacket.device.makeComputePipelineState(function: secondPass)
    }
    
    func random() {
        buffer = Buffer(packet: renderPacket)
    }
    func sort() {
        buffer.sort()
        needrandom = false
    }
}

extension Renderer: MTKViewDelegate {
    func draw(in view: MTKView) {
        
        if needrandom {
            random()
        } else {
            needrandom = true
        }
   
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
        
        // second pass
        commandEncoder.setComputePipelineState(secondState!)
        commandEncoder.setTexture(drawable.texture, index: 0)
        threadsPerGroup = MTLSizeMake(1, 1, 1)
        threadsPerGrid = MTLSizeMake(buffer.count, 1, 1)
        commandEncoder.setBuffer(buffer.buffer, offset: 0, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
