import simd

struct Camera {
    
    var body: Body
    
    var fovRadians: Float = (Float.pi * 2) / 5
    var aspect: Float = 1
    var near: Float = 0.001
    var far: Float = 100
    
    init(position: SIMD3<Float>) {
        body = Body(position: position, rotation: .zero, scale: .one)
    }
    
    var projectionMatrix: simd_float4x4 {
        float4x4(perspectiveWithAspect: aspect, fovy: (Float.pi * 2) / 5, near: near, far: far)
    }
    
    var viewMatrix: simd_float4x4 {
        let translateMatrix = simd_float4x4(translation: body.position)
        let rotateMatrix = simd_float4x4(rotation: body.rotation)
        let scaleMatrix = simd_float4x4(scaling: body.scale)
        return (translateMatrix * scaleMatrix * rotateMatrix)
    }
    
}
