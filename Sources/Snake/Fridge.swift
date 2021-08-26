import CoreStructures
import simd

struct Fridge {
    
    var body: Body
    let transforms: [CoubeTransform]
    
    init() {
        body = Body()
        
        var cubes = [Body]()
        
        (-2...2).forEach { x in
            (-2...2).forEach { y in
                var body = Body()
                body.position.x = 5 * Float(x)
                body.position.y = 5 * Float(y)
                body.position.z = Float(Int.random(in: -2...2)) / 5
                cubes.append(body)
            }
        }
        
        cubes[7].position.z = -5
        
        self.transforms = cubes.map { CoubeTransform(modelMatrix: $0.modelMatrix, normalMatrix: $0.normalMatrix) }

    }
}

