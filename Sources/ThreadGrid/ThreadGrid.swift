import Metal
import Induction
import Algorithms
import RenderSetup

protocol LengthSupplier {
    static var length: Int { get }
}

struct ThreadGrid<Cell: EmptyInit & LengthSupplier> {
    let width: Int
    let height: Int
    let size: Int
    var columns: [[Cell]]
    let buffer: MTLBuffer
    var tempStorage: Array<Cell>
    var plainarray: [Cell] { columns.reduce(into: [Cell]()) { $0 += $1 } }
    var biteSize: Int { size * Cell.length }
    init(device: MTLDevice, width: Int, height: Int) {
        self.width = width
        self.height = height
        size = width * height
        columns = Array(repeating: Array(repeating: Cell(), count: height), count: width)
        buffer = device.makeBuffer(length: size * Cell.length, options: .storageModeShared)!
        tempStorage = Array(repeating: Cell(), count: size)
        fillBuffer()
    }
    func fillBuffer() {
        buffer.contents().copyMemory(from: plainarray, byteCount: size * Cell.length)
    }
    mutating func unbind() {        
        let result = buffer.contents().bindMemory(to: Cell.self, capacity: size)
        for i in tempStorage.indices { tempStorage[i] = result[i] }
        columns = tempStorage.chunks(ofCount: height).map { Array($0) }
    }
    func render() {
        ColumnsToRows(columns: columns)!.rows.forEach { print($0) }
    }
}

struct DebugCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    static var length: Int { MemoryLayout<DebugCell>.stride }
    let info: SIMD4<Float> = [0, 0, 7, 0]
    var description: String { "[\(info.x),\(info.y)]" }
    var isEmpty: Bool { false }
}

struct DebugFridge {
    var grid: ThreadGrid<DebugCell>
    var width: Int { grid.width }
    var height: Int { grid.height }
    init(packet: RenderPacket) {
        grid = ThreadGrid(device: packet.device, width: 8, height: 3)
    }
    mutating func further() {
    }
    mutating func noPassRender() {
        grid.unbind()
        grid.render()
    }
    func render() {
        grid.render()
    }
}

struct DebugQuickPass {
    let renderPacket: RenderPacket
    let state: MTLComputePipelineState
    var fridge: DebugFridge
    init() {
        renderPacket = RenderPacket()        
        let library = renderPacket.library
        let function = library.makeFunction(name: "debugCells")!
        state = try! renderPacket.device.makeComputePipelineState(function: function)
        fridge = DebugFridge(packet: renderPacket)
    }
    func pass() {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(fridge.grid.buffer, offset: 0, index: 0)
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
        fridge.grid.unbind()
        fridge.render()
        count += 1
    }
}
