import Metal
import RenderSetup

class QuickPass {
    
    
    let renderPacket: RenderPacket
    let state: MTLComputePipelineState
    let state2: MTLComputePipelineState
    
    let b1: MoveBuffer
    let b2: MoveBuffer
    let p1: PixelBuffer
    let p2: PixelBuffer
    
    init() {
        
        renderPacket = RenderPacket()        
        let library = renderPacket.library
        let function = library.makeFunction(name: "movePixel")!
        state = try! renderPacket.device.makeComputePipelineState(function: function)
        
        let function2 = library.makeFunction(name: "movePixelLight")!
        state2 = try! renderPacket.device.makeComputePipelineState(function: function2)
        
        b1 = MoveBuffer(packet: renderPacket)
        b2 = MoveBuffer(packet: renderPacket)
        p1 = PixelBuffer(packet: renderPacket)
        p2 = PixelBuffer(packet: renderPacket)
    }
    
    func run() {

        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(b1.mtlbuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(b2.mtlbuffer, offset: 0, index: 1)
        let width = state.threadExecutionWidth
        let height = state.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSizeMake(b1.width, b1.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        
//        commandEncoder.setComputePipelineState(state2)
//        commandEncoder.setBuffer(p1.mtlbuffer, offset: 0, index: 0)
//        commandEncoder.setBuffer(p2.mtlbuffer, offset: 0, index: 1)
//        let width = state.threadExecutionWidth
//        let threadsPerGroup = MTLSizeMake(width, 1, 1)
//        let threadsPerGrid = MTLSizeMake(p1.width, 1, 1)
//        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
//        commandEncoder.endEncoding()
//        commandBuffer.commit()
    }
    
    func verify() {
        let result = b2.unbind()
        result.forEach { print($0) }
    }
}

struct FluidQuickPass {
    let renderPacket: RenderPacket
    let state: MTLComputePipelineState
    var fridge: FluidFridge
    init() {
        renderPacket = RenderPacket()        
        let library = renderPacket.library
        let function = library.makeFunction(name: "moveCellsPrecise")!
        state = try! renderPacket.device.makeComputePipelineState(function: function)
        fridge = FluidFridge(packet: renderPacket)
    }
    func pass() {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(fridge.current.buffer, offset: 0, index: 0)
        commandEncoder.setBuffer(fridge.next.buffer, offset: 0, index: 1)
        let width = state.threadExecutionWidth
        let height = state.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(height, height, 1)
        let threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    mutating func further() {
        fridge.further()
    }
    var count = 0
    mutating func render() {
        print("RENDER: \(count)")
        fridge.white.unbind()
        fridge.black.unbind()
        fridge.current.render()
        count += 1
    }
}


struct QuickPass3D {
    let renderPacket: RenderPacket
    let state: MTLComputePipelineState
    var black: ThreadGridBuffer3D<SnakeCell>
    init() {
        renderPacket = RenderPacket()        
        let library = renderPacket.library
        let function = library.makeFunction(name: "unitAdvectVelocitySnake3D")!
        state = try! renderPacket.device.makeComputePipelineState(function: function)
        black = ThreadGridBuffer3D<SnakeCell>(device: renderPacket.device, width: 4, height: 4, depth: 4)
    }
    func pass() {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(black.buffer, offset: 0, index: 0)
        let width = state.threadExecutionWidth
        let height = state.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSizeMake(black.width, black.height, black.depth)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    mutating func render() {
        black.unbind()
    }
}
