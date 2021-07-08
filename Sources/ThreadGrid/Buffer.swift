import Metal
import Algorithms

struct BufferColor: Equatable, Comparable {
    static func green() -> BufferColor { BufferColor(red: 30, green: 110, blue: 40) }
    static func random() -> BufferColor {
        BufferColor(red: Int.random(in: 10...50), 
                    green: Int.random(in: 100...150), 
                    blue: Int.random(in: 10...50))
    }
    static func randomLight() -> BufferColor {
        BufferColor(red: Int.random(in: 10...20), 
                    green: Int.random(in: 100...110), 
                    blue: Int.random(in: 10...20))
    }
    static func white() -> BufferColor { BufferColor(red: 255, green: 255, blue: 255) }
    let red: Int
    let green: Int
    let blue: Int
    var color: SIMD4<Float> { [Float(red) / 255, Float(green) / 255, Float(blue) / 255, 1] }
    static func < (lhs: BufferColor, rhs: BufferColor) -> Bool {
        lhs.green < rhs.green
    }
}

struct Buffer {
    var buffer: MTLBuffer
    var colors: [BufferColor]
    var count: Int { colors.count }
    let packet: RenderPacket
    init(packet: RenderPacket) {
        self.packet = packet
        let dimension = 100 * 100
        var colors = Array(repeating: BufferColor.white(), count: dimension)
        colors = colors.map { _ in BufferColor.random() }
        self.colors = colors
        let techcolors = colors.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        buffer = packet.device.makeBuffer(bytes: techcolors, length: length, options: .cpuCacheModeWriteCombined)!
    }
    mutating func sort() {
        colors = colors.sorted()
        let techcolors = colors.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        buffer = packet.device.makeBuffer(bytes: techcolors, length: length, options: .cpuCacheModeWriteCombined)!
    }
}

struct BufferTrain {
    var buffer: MTLBuffer
    var colors: [BufferColor]
    var count: Int { colors.count }
    let packet: RenderPacket
    init(packet: RenderPacket) {
        self.packet = packet
        let dimension = 100 * 200
        var colors = Array(repeating: BufferColor.green(), count: dimension)
        colors = colors.map { _ in BufferColor.randomLight() }
        for i in 0...50 { colors[i] = BufferColor(red: 200, green: 100, blue: 150) }
        self.colors = colors
        let techcolors = colors.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        buffer = packet.device.makeBuffer(bytes: techcolors, length: length, options: .cpuCacheModeWriteCombined)!
    }
    mutating func rotate() {
        colors.rotate(toStartAt: 5)
        let techcolors = colors.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        buffer = packet.device.makeBuffer(bytes: techcolors, length: length, options: .cpuCacheModeWriteCombined)!
    }
}

struct BufferOne {
    static var buffer: MTLBuffer?
    var colors: [BufferColor]
    var count: Int { colors.count }
    var buffer: MTLBuffer { BufferOne.buffer! }
    let packet: RenderPacket
    let width = 200
    let height = 100
    
    init(packet: RenderPacket) {
        self.packet = packet
        var colors = Array(repeating: BufferColor.green(), count: width * height)
        colors = colors.map { _ in BufferColor.randomLight() }
        for i in 0...50 { colors[i] = BufferColor(red: 200, green: 100, blue: 150) }
        self.colors = colors
        let techcolors = colors.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        BufferOne.buffer = packet.device.makeBuffer(bytes: techcolors, length: length, options: .cpuCacheModeWriteCombined)!
    }
    mutating func rotate() {
        colors.rotate(toStartAt: 5)
        let techcolors = colors.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        BufferOne.buffer!.contents().copyMemory(from: techcolors, byteCount: length)
    }
}

struct RowBuffer {
    static var buffer: MTLBuffer?
    let width = 200
    let height = 100
    var rows: [[BufferColor]]
    var buffer: MTLBuffer { BufferOne.buffer! }
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
        BufferOne.buffer = packet.device.makeBuffer(bytes: array, length: length, options: .cpuCacheModeWriteCombined)!
    }
    mutating func rotate() {
        rows.rotate(toStartAt: 5)
        fillBuffer()
    }
    mutating func shuffle() {
        rows.shuffle()
        fillBuffer()
    }
    mutating func fullRotate() {
        
        rows.rotate(toStartAt: 1)
        
        var array = rows.reduce([BufferColor]()) { $0 + $1 }
        array.rotate(toStartAt: 10)
        rows = array.chunks(ofCount: width).map { chunk in Array(chunk) }
        
        let colors = array.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * colors.count
        BufferOne.buffer!.contents().copyMemory(from: colors, byteCount: length)
        print("full rotate")
    }
    mutating func fillBuffer() {
        let array = rows.reduce([BufferColor]()) { $0 + $1 }.map { $0.color }
        let length = MemoryLayout<SIMD4<Float>>.stride * array.count
        BufferOne.buffer!.contents().copyMemory(from: array, byteCount: length)
    }
}
