import Metal

struct BufferColor: Comparable {
    static func random() -> BufferColor {
        BufferColor(red: Int.random(in: 10...50), 
                    green: Int.random(in: 100...150), 
                    blue: Int.random(in: 10...50))
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
