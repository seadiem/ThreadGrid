import Metal

struct FluidCell: CustomStringConvertible {
    static var zero: FluidCell { FluidCell(velocity: .zero, density: 0) }
    static var length: Int { MemoryLayout<FluidCell>.stride }
    let temp: SIMD2<Float> = .zero
    var velocity: SIMD2<Float>
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
    var tempStorage = Array(repeating: FluidCell.zero, count: FluidGrid.size)
    var plainarray: [FluidCell] { rows.reduce(into: [FluidCell]()) { $0 += $1 } }
    init(device: MTLDevice) {
        rows = Array(repeating: Array(repeating: FluidCell.zero, count: FluidGrid.width), count: FluidGrid.height)
        buffer = device.makeBuffer(length: FluidGrid.size * FluidCell.length, options: .storageModeShared)!
        fillBuffer()
    }
    func fillBuffer() {
        buffer.contents().copyMemory(from: plainarray, byteCount: FluidGrid.size * FluidCell.length)
    }
    mutating func unbind() {        
        let result = buffer.contents().bindMemory(to: FluidCell.self, capacity: FluidGrid.size)
        for i in tempStorage.indices { tempStorage[i] = result[i] }
        rows = tempStorage.chunks(ofCount: FluidGrid.width).map { Array($0) }
    }
    func render() {
        rows.forEach {print($0)}
    }
}

struct FluidFridge {
    enum State { 
        case black, white
        mutating func further() {
            switch self {
            case .black: self = .white
            case .white: self = .black
            }
        }
    }
    var black: FluidGrid
    var white: FluidGrid
    var state: State
    var current: FluidGrid {
        switch state {
        case .black: return black
        case .white: return white
        }
    }
    var next: FluidGrid {
        switch state {
        case .black: return white
        case .white: return black
        }
    }
    init(packet: RenderPacket) {
        black = FluidGrid(device: packet.device)
        white = FluidGrid(device: packet.device)
        state = .black
        black.rows[0][0].density = 1.0
        black.rows = black.rows.map { row in 
            row.map { cell in
                var cell = cell
                cell.velocity = [1, 1]
                return cell
            }
        }
        black.fillBuffer()
        white.rows = black.rows
        white.fillBuffer()
    }
    mutating func further() {
        state.further()
    }
    mutating func noPassRender() {
        black.unbind()
        black.render()
    }
    func render() {
        next.render()
//        print("black")
//        black.render()
//        print("white")
//        white.render()
    }
}
import MetalKit
class AdvectRenderer: NSObject, MTKViewDelegate  {
    let renderPacket: RenderPacket
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        super.init()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    public func draw(in view: MTKView) {}
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
        let threadsPerGrid = MTLSizeMake(FluidGrid.width, FluidGrid.height, 1)
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
        fridge.render()
        count += 1
    }
}


