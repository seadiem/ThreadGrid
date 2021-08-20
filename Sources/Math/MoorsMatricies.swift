import simd
import CoreGraphics

public extension double4x4 {
    /// Creates a 4x4 matrix representing a translation given by the provided vector.
    /// - parameter vector: Vector giving the direction and magnitude of the translation.
    init(translate vector: SIMD3<Double>) {
        // List of the matrix' columns
        let baseX: SIMD4<Double> = [1, 0, 0, 0]
        let baseY: SIMD4<Double> = [0, 1, 0, 0]
        let baseZ: SIMD4<Double> = [0, 0, 1, 0]
        let baseW: SIMD4<Double> = [vector.x, vector.y, vector.z, 1]
        self.init(baseX, baseY, baseZ, baseW)
    }
    
    /// Creates a 4x4 matrix representing a uniform scale given by the provided scalar.
    /// - parameter s: Scalar giving the uniform magnitude of the scale.
    init(scale s: Double) {
        self.init(diagonal: [s, s, s, 1])
    }
    
    /// Creates a 4x4 matrix that will rotate through the given vector and given angle.
    /// - parameter angle: The amount of radians to rotate from the given vector center.
    init(rotate vector: SIMD3<Double>, angle: Double) {
        let c: Double = cos(angle)
        let s: Double = sin(angle)
        let cm = 1 - c
        
        let x0 = vector.x*vector.x + (1-vector.x*vector.x)*c
        let x1 = vector.x*vector.y*cm - vector.z*s
        let x2 = vector.x*vector.z*cm + vector.y*s
        
        let y0 = vector.x*vector.y*cm + vector.z*s
        let y1 = vector.y*vector.y + (1-vector.y*vector.y)*c
        let y2 = vector.y*vector.z*cm - vector.x*s
        
        let z0 = vector.x*vector.z*cm - vector.y*s
        let z1 = vector.y*vector.z*cm + vector.x*s
        let z2 = vector.z*vector.z + (1-vector.z*vector.z)*c
        
        // List of the matrix' columns
        let baseX: SIMD4<Double> = [x0, x1, x2, 0]
        let baseY: SIMD4<Double> = [y0, y1, y2, 0]
        let baseZ: SIMD4<Double> = [z0, z1, z2, 0]
        let baseW: SIMD4<Double> = [ 0,  0,  0, 1]
        self.init(baseX, baseY, baseZ, baseW)
    }
    
    /// Creates a perspective matrix from an aspect ratio, field of view, and near/far Z planes.
    init(perspectiveWithAspect aspect: Double, fovy: Double, near: Double, far: Double) {
        let yScale = 1 / tan(fovy * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange
        
        
        
        // List of the matrix' columns
        let vectorP: SIMD4<Double> = [xScale,      0,       0,  0]
        let vectorQ: SIMD4<Double> = [     0, yScale,       0,  0]
        let vectorR: SIMD4<Double> = [     0,      0,  zScale, -1]
        let vectorS: SIMD4<Double> = [     0,      0, wzScale,  0]
        self.init(vectorP, vectorQ, vectorR, vectorS)
    }
}

public extension float4x4 {
    /// Creates a 4x4 matrix representing a translation given by the provided vector.
    /// - parameter vector: Vector giving the direction and magnitude of the translation.
    init(translate vector: SIMD3<Float>) {
        // List of the matrix' columns
        let baseX: SIMD4<Float> = [1, 0, 0, 0]
        let baseY: SIMD4<Float> = [0, 1, 0, 0]
        let baseZ: SIMD4<Float> = [0, 0, 1, 0]
        let baseW: SIMD4<Float> = [vector.x, vector.y, vector.z, 1]
        self.init(baseX, baseY, baseZ, baseW)
    }
    
    /// Creates a 4x4 matrix representing a uniform scale given by the provided scalar.
    /// - parameter s: Scalar giving the uniform magnitude of the scale.
    init(scale s: Float) {
        self.init(diagonal: [s, s, s, 1])
    }
    
    /// Creates a 4x4 matrix that will rotate through the given vector and given angle.
    /// - parameter angle: The amount of radians to rotate from the given vector center.
    init(rotate vector: SIMD3<Float>, angle: Float) {
        let c: Float = cos(angle)
        let s: Float = sin(angle)
        let cm = 1 - c
        
        let x0 = vector.x*vector.x + (1-vector.x*vector.x)*c
        let x1 = vector.x*vector.y*cm - vector.z*s
        let x2 = vector.x*vector.z*cm + vector.y*s
        
        let y0 = vector.x*vector.y*cm + vector.z*s
        let y1 = vector.y*vector.y + (1-vector.y*vector.y)*c
        let y2 = vector.y*vector.z*cm - vector.x*s
        
        let z0 = vector.x*vector.z*cm - vector.y*s
        let z1 = vector.y*vector.z*cm + vector.x*s
        let z2 = vector.z*vector.z + (1-vector.z*vector.z)*c
        
        // List of the matrix' columns
        let baseX: SIMD4<Float> = [x0, x1, x2, 0]
        let baseY: SIMD4<Float> = [y0, y1, y2, 0]
        let baseZ: SIMD4<Float> = [z0, z1, z2, 0]
        let baseW: SIMD4<Float> = [ 0,  0,  0, 1]
        self.init(baseX, baseY, baseZ, baseW)
    }
    
    /// Creates a perspective matrix from an aspect ratio, field of view, and near/far Z planes.
    init(perspectiveWithAspect aspect: Float, fovy: Float, near: Float, far: Float) {
        let yScale = 1 / tan(fovy * 0.5)
        let xScale = yScale / aspect
        let zRange = far - near
        let zScale = -(far + near) / zRange
        let wzScale = -2 * far * near / zRange
        
    
        
        // List of the matrix' columns
        let vectorP: SIMD4<Float> = [xScale,      0,       0,  0]
        let vectorQ: SIMD4<Float> = [     0, yScale,       0,  0]
        let vectorR: SIMD4<Float> = [     0,      0,  zScale, -1]
        let vectorS: SIMD4<Float> = [     0,      0, wzScale,  0]
        self.init(vectorP, vectorQ, vectorR, vectorS)
    }
}
