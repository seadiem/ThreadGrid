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

public struct Stencil3D {
    static let stencil3x3: Stencil3D = Stencil3D(profile: Stencil2D()) 
    let offsets: [SIMD3<Float>]
    let cStencil: Stencil3x3
    public var length: Int { MemoryLayout<Stencil3x3>.stride }
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
        
        self.cStencil = self.offsets.withUnsafeBytes {
            return $0.load(as: Stencil3x3.self) 
            // This is allowed because Stencil3x3 only has one
            // stored property (a tuple of 26 SIMD3<Float>
            // instances), so its layout is the same as its stored property.
            // look LINKS
        }
    }
}

struct TestStencil {
    func run() {
        let stencil = Stencil3D.stencil3x3
        print("count: \(stencil.cStencil.offsets)")
    }
}

// LINKS
// https://forums.swift.org/t/how-to-use-c-api-with-fixed-size-cs-array/51569/7
