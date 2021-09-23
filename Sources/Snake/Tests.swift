import MetalKit
import RenderSetup
import CoreStructures

public struct SnakeTest {
    public init() {}
    public func run() {
//        InspectMesh().run()
        Different().run()
    }
}

extension IOVertex: CustomStringConvertible {
    static var zero: IOVertex { IOVertex(position: .zero, normal: .zero, textureCoordinate: .zero) }
    public var description: String { 
        
        let n = normal
        let p = position
        let uv = textureCoordinate
        
        return "[p:\(p.x) \(p.y) \(p.z) n:\(n.x) \(n.y) \(n.z) uv:\(uv.x) \(uv.y)]"
//        return "[n:\(n.x) \(n.y) \(n.z)]"
    }
}

extension IOVertex2: CustomStringConvertible {
    static var zero: IOVertex2 { IOVertex2(position: .zero, normal: .zero) }
    public var description: String { 
        
        let n = normal
        let p = position
        
        return "[p:\(p.x) \(p.y) \(p.z) n:\(n.x) \(n.y) \(n.z)]"
    }
}

struct InspectMesh {
    func run() {
        let renderPacket = RenderPacket()
        let allocator = MTKMeshBufferAllocator(device: renderPacket.device)
        let iomesh = MDLMesh(boxWithExtent: [5, 5, 5],segments: [1, 1, 1],
                             inwardNormals: false, geometryType: .triangles,
                             allocator: allocator)
        iomesh.vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor
        let mesh = try! MTKMesh(mesh: iomesh, device: renderPacket.device)
        let buf = mesh.vertexBuffers[0].buffer
        print(mesh.vertexCount)
        
        var array = Array(repeating: IOVertex2.zero, count: mesh.vertexCount)
        
        let result = buf.contents().bindMemory(to: IOVertex2.self, capacity: array.count)
        for i in array.indices { array[i] = result[i] }
        array.forEach { print($0) }
        
        print(mesh.vertexDescriptor)
    }
}

struct TestRotation {
    
    
    func map(touch: SIMD2<Float>) {
//        print("touch: \(touch)")
        let ihat: SIMD3<Float> = [1, 0, 0]
        let jhat: SIMD3<Float> = [0, 1, 0]
        let khat: SIMD3<Float> = [300, 200, 1]
        let matrix = simd_float3x3([ihat, jhat, khat])
        let touch3: SIMD3<Float> = [touch.x, touch.y, 1] 
        let mapped = matrix.inverse * touch3
 //       print("mapped: \(mapped)")
        getAngel(direction: [mapped.x, mapped.y])
    }
    
    func getAngel(direction: SIMD2<Float>) {
        let a = atan(direction.y / direction.x)
        let alpha = atan2(direction.y, direction.x)
        print("a: \(a), alpha: \(alpha)")
    }
    
}

struct Different {

    func run() {
        let exists = ["Cat", "Dog", "Mouse"]
        let incom = ["Cat", "Dog", "Mouse", "Fish", "Monkey"]
        let diff = incom.difference(from: exists)
        print(type(of: diff))
        diff.forEach { print($0) }
    }
    
}
