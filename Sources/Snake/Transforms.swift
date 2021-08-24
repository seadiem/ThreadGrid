
import simd

struct Body: Equatable {
    var position: SIMD3<Float> = [0, 0, 0]
    var rotation: SIMD3<Float> = [0, 0, 0]
    var scale: SIMD3<Float> = [1, 1, 1]
    
    var modelMatrix: simd_float4x4 {
        let translateMatrix = simd_float4x4(translation: position)
        let rotateMatrix = simd_float4x4(rotation: rotation)
        let scaleMatrix = simd_float4x4(scaling: scale)
        return translateMatrix * rotateMatrix * scaleMatrix
    }
    
    var normalMatrix: simd_float3x3 {
        return simd_float3x3(normalFrom4x4: modelMatrix)
    }
}

struct Camera {
    
    var body: Body
    
    var fovRadians: Float = (Float.pi * 2) / 5
    var aspect: Float = 1
    var near: Float = 0.001
    var far: Float = 100
    
    init(position: SIMD3<Float>) {
        body = Body(position: position, rotation: .zero, scale: .one)
    }
    
//    var projectionMatrix: simd_float4x4 {
//        simd_float4x4(projectionFov: fovRadians, near: near, far: far, aspect: aspect)
//    }
    
    var projectionMatrix: simd_float4x4 {
        float4x4(perspectiveWithAspect: aspect, fovy: (Float.pi * 2) / 5, near: 1, far: 100)
    }
    
    var viewMatrix: simd_float4x4 {
        let translateMatrix = simd_float4x4(translation: body.position)
        let rotateMatrix = simd_float4x4(rotation: body.rotation)
        let scaleMatrix = simd_float4x4(scaling: body.scale)
        return (translateMatrix * scaleMatrix * rotateMatrix)
    }
    
}



