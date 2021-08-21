import simd
import Math

public struct ModelTransformation {
    
    static var zero: ModelTransformation { ModelTransformation() }
    
    var ihat: SIMD3<Float>
    var jhat: SIMD3<Float>
    var khat: SIMD3<Float>
    
    public init() {
        ihat = [1, 0, 0]
        jhat = [0, 1, 0]
        khat = [0, 0, 1]
    }
    
    public mutating func setZ(scale: Float) {
        khat = [0, 0, scale]
    }
    
    public mutating func setXY(scale: Float) {
        ihat = [scale, 0, 0]
        jhat = [0, scale, 0]
    }
    
    var matrix: simd_float4x4 {
        let i = SIMD4(ihat, 0)
        let j = SIMD4(jhat, 0)
        let k = SIMD4(khat, 0)
        let m = SIMD4<Float>([0, 0, 0, 1])
        let matrix = simd_float4x4(columns: (i, j, k, m))
        return matrix
    }
    
}
