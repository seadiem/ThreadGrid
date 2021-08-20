import Metal
import Algorithms
import RenderSetup


struct PixelBuffer {
    let mtlbuffer: MTLBuffer
    let width = 40
    init(packet: RenderPacket) {
        let pixel = MoveBuffer.Pixel(velocity: .one, color: .one)
        let pixels = Array(repeating: pixel, count: width)
        mtlbuffer = packet.device.makeBuffer(bytes: pixels, length: pixel.length * pixels.count, options: .cpuCacheModeWriteCombined)!
    }
    func unbind() -> [MoveBuffer.Pixel] {
        let result = mtlbuffer.contents().bindMemory(to: MoveBuffer.Pixel.self, capacity: width)
        var pixels = Array(repeating: MoveBuffer.Pixel(velocity: .one, color: .one), count: width)
        for i in 0 ..< width { 
            pixels[i] = result[i]
        }
        return pixels
    }
}

struct MoveBuffer {
    
    struct Pixel {
        
        var ids: (UInt32, UInt32, UInt32, UInt32, UInt32) = (1, 2, 3, 4, 5)
        let velocity: SIMD2<Float>
        let color: SIMD4<Float>
        
        var length: Int { MemoryLayout<Pixel>.stride }
        mutating func check() {
            ids.1 = 2
        }
    }
    
    struct Rows {
        let pixels: [[Pixel]]
        var length: Int {
            var current = 0
            for row in pixels {
                for pixel in row {
                    current += pixel.length
                }
            }
            return current
        }
        var plainarray: [Pixel] {
            pixels.reduce(into: [Pixel]()) { $0 += $1 }
        }
    }
    
    
    let mtlbuffer: MTLBuffer
    let width = 40
    let height = 30
    init(packet: RenderPacket) {
        let pixels = Array(repeating: Pixel(velocity: .one, color: .one), count: width)
        let rows = Rows(pixels: Array(repeating: pixels, count: height))
//        mtlbuffer = packet.device.makeBuffer(bytes: rows.pixels, length: rows.length, options: .cpuCacheModeWriteCombined)!
        mtlbuffer = packet.device.makeBuffer(bytes: rows.plainarray, length: rows.length, options: .cpuCacheModeWriteCombined)!
    }
    func unbind() -> [Pixel] {
        let result = mtlbuffer.contents().bindMemory(to: Pixel.self, capacity: height * width)
        var pixels = Array(repeating: Pixel(velocity: .one, color: .one), count: width * height)
        for i in 0..<height * width { 
            pixels[i] = result[i]
        }
        return pixels
    }
}

struct RowBuffer {
    static var buffer: MTLBuffer?
    let width = 400
    let height = 300
    var rows: [[BufferColor]]
    var buffer: MTLBuffer { RowBuffer.buffer! }
    let count: Int
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
        count = array.count
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
