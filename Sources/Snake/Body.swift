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
