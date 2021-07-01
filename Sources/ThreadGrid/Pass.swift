import Metal

struct Pass {
    
    let computeEncoder: MTLComputeCommandEncoder
    
    func pass(origin: [Float], result: MTLBuffer) {
        computeEncoder.setBytes(origin, length: MemoryLayout<Float>.stride * origin.count, index: 1)
        computeEncoder.setBuffer(result, offset: 0, index: 0)
        let gridsize =  MTLSizeMake(origin.count, 1, 1)
        let threadgroupsize = MTLSizeMake(100, 1, 1)
        computeEncoder.dispatchThreads(gridsize, threadsPerThreadgroup: threadgroupsize)
        computeEncoder.endEncoding()
    }
    
    func pass(buffer: MTLBuffer, result: MTLBuffer) {
        computeEncoder.setBuffer(buffer, offset: 0, index: 1)
        computeEncoder.setBuffer(result, offset: 0, index: 0)
        let gridsize =  MTLSizeMake(10, 1, 1)
        let threadgroupsize = MTLSizeMake(100, 1, 1)
        computeEncoder.dispatchThreads(gridsize, threadsPerThreadgroup: threadgroupsize)
        computeEncoder.endEncoding()
    }
    
}
