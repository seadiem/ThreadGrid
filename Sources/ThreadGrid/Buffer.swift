import Metal
import Algorithms

struct RowBuffer {
    static var buffer: MTLBuffer?
    let width = 400
    let height = 300
    var rows: [[BufferColor]]
    var buffer: MTLBuffer { RowBuffer.buffer! }
    init(packet: RenderPacket) {
        var rows = [[BufferColor]]()
        for index in 0..<height {
            let row = Array(repeating: BufferColor(red: 10 + index, green: 10, blue: 10), count: width)
            rows.append(row)
        }
        let minirow = Array(repeating: BufferColor(red: 200, green: 100, blue: 150), count: 20)
        rows[0].replaceSubrange(minirow.indices, with: minirow)
        self.rows = rows
        let array = rows.reduce([BufferColor]()) { $0 + $1 }.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * array.count
        RowBuffer.buffer = packet.device.makeBuffer(bytes: array, length: length, options: .cpuCacheModeWriteCombined)!
    }
    mutating func rotate() {
        rows.rotate(toStartAt: 5)
        fillBuffer()
    }
    mutating func shuffle() {
        rows.shuffle()
        fillBuffer()
    }
    mutating func fillBuffer() {
        let array = rows.reduce([BufferColor]()) { $0 + $1 }.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * array.count
        RowBuffer.buffer!.contents().copyMemory(from: array, byteCount: length)
    }
    mutating func fullRotate() {
        
        rows.rotate(toStartAt: 1)
        
        var array = rows.reduce([BufferColor]()) { $0 + $1 }
        array.rotate(toStartAt: 10)
        rows = array.chunks(ofCount: width).map { chunk in Array(chunk) }
        
        let colors = array.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        RowBuffer.buffer!.contents().copyMemory(from: colors, byteCount: length)
    }
    mutating func fullShuffle() {
        var array = rows.reduce([BufferColor]()) { $0 + $1 }
        array.shuffle()
        rows = array.chunks(ofCount: width).map { chunk in Array(chunk) }
        let colors = array.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        RowBuffer.buffer!.contents().copyMemory(from: colors, byteCount: length)
    }
    mutating func fullPartition() {
        var array = rows.reduce([BufferColor]()) { $0 + $1 }
        _ = array.stablePartition { color -> Bool in color.red > 60 }
        rows = array.chunks(ofCount: width).map { chunk in Array(chunk) }
        let colors = array.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        RowBuffer.buffer!.contents().copyMemory(from: colors, byteCount: length)
    }
    mutating func fullSort() {
        var array = rows.reduce([BufferColor]()) { $0 + $1 }
        array.sort()
        rows = array.chunks(ofCount: width).map { chunk in Array(chunk) }
        let colors = array.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        RowBuffer.buffer!.contents().copyMemory(from: colors, byteCount: length)
    }
}
