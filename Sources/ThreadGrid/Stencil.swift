import simd
import Math
import CoreStructures

struct Stencil2D {
    let offsets: [SIMD2<Int>] = [
        [-1, 1],
        [ 0, 1],
        [ 1, 1],
        [-1, 0],
        [ 1, 0],
        [-1,-1],
        [ 0,-1],
        [ 1,-1],
    ]
}

extension Stencil3x3 {
    init?(array: [SIMD3<Float>]) {
        let arrayByteSize = array.count * MemoryLayout<SIMD3<Float>>.stride
        let cArrayByteSize = MemoryLayout<Self>.size
        guard arrayByteSize == cArrayByteSize else { return nil }
        guard let cArray = array.withUnsafeBytes({ ptr -> Stencil3x3? in
            guard let baseAddress = ptr.baseAddress else { return nil }
            let cPtr = baseAddress.assumingMemoryBound(to: Self.self)
            return cPtr.pointee
        }) else { return nil }
        self = cArray
    }
}

struct Stencil3D {
    static let stencil3x3: Stencil3D = Stencil3D(profile: Stencil2D()) 
    let offsets: [SIMD3<Float>]
    let cStencil: Stencil3x3 
    init(profile: Stencil2D) {
        let offsets = profile.offsets.map { v -> SIMD3<Int> in [v.x, v.y, 0] }
        var out = [SIMD3<Int>]()
        out += offsets
        out += offsets.map { vector in
            var o = vector
            o.z = -1
            return o
        }
        out += offsets.map { vector in
            var o = vector
            o.z = 1
            return o
        }
        out.append([0, 0, 1])
        out.append([0, 0, -1])
        self.offsets = out.map { SIMD3<Float>($0) }
        self.cStencil = Stencil3x3(array: self.offsets)!
    }

}

struct TestStencil {
    func run() {
        let stencil = Stencil3D.stencil3x3
        print("count: \(stencil.cStencil.offsets)")
    }
}
