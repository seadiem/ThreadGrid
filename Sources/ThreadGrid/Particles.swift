import Metal

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
}
