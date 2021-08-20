import Metal
import simd
import RenderSetup

struct Butterfly: Equatable, Hashable {
    let id: Int
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    static func == (lhs: Butterfly, rhs: Butterfly) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Butterflies {
    var particleBuffer: MTLBuffer
    var incects: [Butterfly]
    let count = 10
    init(packet: RenderPacket) {
        var incects = [Butterfly]() 
        for i in 0..<count {
            let position: SIMD2<Float> = [10 * Float(i), 10]
            let velocity: SIMD2<Float> = [0, 0.1]
            let butterfly = Butterfly(id: i, position: position, velocity: velocity)
            incects.append(butterfly)
        }
        self.incects = incects
        let length = MemoryLayout<Butterfly>.stride * incects.count
        particleBuffer = packet.device.makeBuffer(bytes: incects, length: length, options: .cpuCacheModeWriteCombined)!
    }
    mutating func select(at point: SIMD2<Float>, current: Butterfly) -> Butterfly? {
        let result = particleBuffer.contents().bindMemory(to: Butterfly.self, capacity: count)
        var array = Array(repeating: Butterfly(id: 0, position: .zero, velocity: .zero), count: count)
        for i in 0 ..< count { array[i] = result[i] }
        array.sort { distance(point, $0.position) < distance(point, $1.position) }
        if distance(array.first!.position, point) < distance(current.position, point) {
            let last = array.removeFirst()
            array.append(current)
            let length = MemoryLayout<Butterfly>.stride * count
            particleBuffer.contents().copyMemory(from: array, byteCount: length)
            incects = array
            return last
        } else {
            return nil
        }
    }
}
