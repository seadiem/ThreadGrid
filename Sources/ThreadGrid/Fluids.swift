import Metal

struct FluidCell: CustomStringConvertible {
    static var length: Int { MemoryLayout<FluidCell>.stride }
    let temp: SIMD2<Float> = .zero
    let velocity: SIMD2<Float>
    var density: Float
    var char: Character {
        if density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
//    var description: String { "[\(temp.x), \(temp.y)]" }
    var description: String { String(char) }
//    var description: String { "[\(velocity.x), \(velocity.y)]" }
//    var description: String { "[\(density)]" }
}

struct FluidGrid {
    static let width: Int = 10
    static let height: Int = 5
    static var size: Int { width * height }
    var rows: [[FluidCell]]
    let buffer: MTLBuffer
    var plainarray: [FluidCell] { rows.reduce(into: [FluidCell]()) { $0 += $1 } }
    init(device: MTLDevice) {
        var rows = [[FluidCell]]()
        for _ in 0..<FluidGrid.height {
            let row = Array(repeating: FluidCell(velocity: [1, 1], density: 0.1), count: FluidGrid.width)
            rows.append(row)
        }
        self.rows = rows
        buffer = device.makeBuffer(bytes: rows.reduce(into: [FluidCell]()) { $0 += $1 }, 
                                   length: FluidGrid.size * FluidCell.length, options: .storageModeShared)!
    }
    func fillBuffer() {
        buffer.contents().copyMemory(from: plainarray, byteCount: FluidGrid.size)
    }
    mutating func unbind() {
        let result = buffer.contents().bindMemory(to: FluidCell.self, capacity: FluidGrid.size)
        var pixels = Array(repeating: FluidCell(velocity: [1, 1], density: 0.1), count: FluidGrid.size)
        for i in pixels.indices { 
            pixels[i] = result[i]
        }
//        print("")
//        pixels.forEach { print($0) }
        rows = pixels.chunks(ofCount: FluidGrid.width).map { Array($0) }
    }
    func render() {
        rows.forEach {print($0)}
    }
}

struct FluidFridge {
    enum State { 
        case black, white
        mutating func next() {
            switch self {
            case .black: self = .white
            case .white: self = .black
            }
        }
    }
    var black: FluidGrid
    var white: FluidGrid
    var state: State
    var currentBuffer: MTLBuffer {
        black.buffer
//        switch state {
//        case .black: return black.buffer
//        case .white: return white.buffer
//        }
    }
    var nextBuffer: MTLBuffer {
        white.buffer
//        switch state {
//        case .black: return white.buffer
//        case .white: return black.buffer
//        }
    }
    init(packet: RenderPacket) {
        black = FluidGrid(device: packet.device)
        white = FluidGrid(device: packet.device)
        state = .black
        black.rows[0][0].density = 1.0
        black.fillBuffer()
    }
    func render() {
        print("black")
        black.render()
        print("\nwhite")
        white.render()
    }
}

struct FluidQuickPass {
    let renderPacket: RenderPacket
    let state: MTLComputePipelineState
    var fridge: FluidFridge
    init() {
        renderPacket = RenderPacket()        
        let library = renderPacket.library
        let function = library.makeFunction(name: "moveCells")!
        state = try! renderPacket.device.makeComputePipelineState(function: function)
        fridge = FluidFridge(packet: renderPacket)
    }
    func pass() {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(fridge.currentBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(fridge.nextBuffer, offset: 0, index: 1)
        let width = state.threadExecutionWidth
        let height = state.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(height, height, 1)
        let threadsPerGrid = MTLSizeMake(FluidGrid.width, FluidGrid.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    mutating func render() {
        fridge.white.unbind()
        fridge.black.unbind()
        fridge.render()
    }
}


