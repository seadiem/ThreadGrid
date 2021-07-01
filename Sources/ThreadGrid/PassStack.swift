import Metal

struct PassStack {
    


    
    init(packet: RenderPacket) {
        
        
        var array: [Float] = [1, 2, 3, 4, 5, 6]
        let origin = array
        
        
        let computeFunction = packet.library.makeFunction(name: "grid1")!
        let computePipelineState = try! packet.device.makeComputePipelineState( function: computeFunction)
        let state = computePipelineState
        
        let length = MemoryLayout<Float>.stride * origin.count
        let resultbuffer1 = packet.device.makeBuffer(length: length, options: .storageModeShared)!
        let resultbuffer2 = packet.device.makeBuffer(length: length, options: .storageModeShared)!
        
        
        let commandBuffer = packet.commandQueue.makeCommandBuffer()!
        var computeEncoder = commandBuffer.makeComputeCommandEncoder(dispatchType: .serial)!
        computeEncoder.setComputePipelineState(state)
        var pass = Pass(computeEncoder: computeEncoder)
        pass.pass(origin: array, result: resultbuffer1)
        
        computeEncoder = commandBuffer.makeComputeCommandEncoder(dispatchType: .serial)!
        computeEncoder.setComputePipelineState(state)
        pass = Pass(computeEncoder: computeEncoder)
        let r1 = retriveResult(count: array.count, buffer: resultbuffer1)
        print("r1: \(r1)")
        pass.pass(buffer: resultbuffer1, result: resultbuffer2)
        
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let result = retriveResult(count: array.count, buffer: resultbuffer2)
        print("result: \(result)")
    
    }
    
    func retriveResult(count: Int, buffer: MTLBuffer) -> [Float] {
        let result = buffer.contents().bindMemory(to: Float.self, capacity: count)
        var outdata = [Float](repeating: 0, count: count)
        for index in 0..<count { 
            outdata[index] = result[index] 
        }
        return outdata
    }
    
}
