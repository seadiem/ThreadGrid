import simd
import Math

public struct Matricies {
    
    let screen: SIMD2<Float>
    let translateIntoModelCoords: SIMD3<Float>
    let rotation: SIMD3<Float>
    let moveCamera: SIMD3<Float>
    let localModelTransform: ModelTransformation
    
    var modelMatrix: simd_float4x4 {
        float4x4(translate: translateIntoModelCoords) * localModelTransform.matrix
    }
    
    var viewMatrix: simd_float4x4 {
        let xRotScene = float4x4(rotate: [1, 0, 0], angle: rotation.x)
        let yRotScene = float4x4(rotate: [0, 1, 0], angle: rotation.y)
        let zRotScene = float4x4(rotate: [0, 0, 1], angle: rotation.z)
        let moovecamera = float4x4(translate: moveCamera)
        let matrix = moovecamera * (xRotScene * yRotScene * zRotScene) 
        return  matrix
    }
    
    var projectionMatrix: simd_float4x4 {
        float4x4(perspectiveWithAspect: screen.x/screen.y, fovy: (Float.pi * 2) / 5, near: 1, far: 100)
    }
    
    public init(screen: SIMD2<Float>, 
                position: SIMD3<Float>,
                rotation: SIMD3<Float>,
                moveCamera: SIMD3<Float>,
                localTransform: ModelTransformation) {
        self.screen = screen
        self.rotation = rotation
        self.translateIntoModelCoords = position
        self.moveCamera = moveCamera
        self.localModelTransform = localTransform
    }
    
}
