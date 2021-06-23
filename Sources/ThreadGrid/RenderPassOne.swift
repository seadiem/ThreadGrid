import Metal

struct RenderPassOne {
    
    let commandBuffer: MTLCommandBuffer
    let state: MTLComputePipelineState
    let origin: [Float]
    let result: MTLBuffer
    let done: ([Float]) -> Void
    
    init(packet: RenderPacket, origin: [Float], done: @escaping ([Float]) -> Void) {
        let computeFunction = packet.library.makeFunction(name: "grid1")!
        let computePipelineState = try! packet.device.makeComputePipelineState( function: computeFunction)
        self.state = computePipelineState
        self.commandBuffer = packet.commandQueue.makeCommandBuffer()!
        self.origin = origin
        
        let length = MemoryLayout<Float>.stride * origin.count
        let resultbuffer = packet.device.makeBuffer(length: length, options: .storageModeShared)!
        self.result = resultbuffer
        self.done = done
    }
    
    func pass() {
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setComputePipelineState(state)
        computeEncoder.setBytes(origin, length: MemoryLayout<Float>.stride * origin.count, index: 1)
        computeEncoder.setBuffer(result, offset: 0, index: 0)
        
        let gridsize =  MTLSizeMake(origin.count, 1, 1)
        let threadgroupsize = MTLSizeMake(100, 1, 1)
        computeEncoder.dispatchThreads(gridsize, threadsPerThreadgroup: threadgroupsize)
        
        
        computeEncoder.endEncoding()
        commandBuffer.addCompletedHandler { _ in handleResult() }
        commandBuffer.commit()
    }
    
    
    func handleResult() {
        let result = self.result.contents().bindMemory(to: Float.self, capacity: origin.count)
        var outdata = [Float](repeating: 0, count: origin.count)
        for index in origin.indices { 
            outdata[index] = result[index] 
        }
        done(outdata)
    }
    
}
