import CoreStructures
import simd

struct Fridge {
    
    var body: Body
    let transforms: [CoubeTransform]
    
    init() {
        body = Body()
        
        var position: SIMD3<Float> = [0, -2.5, 0]
        var translateMatrix = simd_float4x4(translation: position)
        let rotateMatrix = simd_float4x4(rotation: .zero)
        let scaleMatrix = simd_float4x4(scaling: .one)
        var modelMatrix = translateMatrix * rotateMatrix * scaleMatrix
        var transforms = [CoubeTransform]()
        transforms.append(CoubeTransform(modelMatrix: modelMatrix))
        position.y += 5.01
        translateMatrix = simd_float4x4(translation: position)
        modelMatrix = translateMatrix * rotateMatrix * scaleMatrix
        transforms.append(CoubeTransform(modelMatrix: modelMatrix))
        self.transforms = transforms
    }
}

