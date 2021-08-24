import MetalKit
import RenderSetup


class CoubeFridge {
    
}

class Coub {
    
    let mesh: MTKMesh 
    var body: Body
    
    init(renderPacket: RenderPacket, size: SIMD3<Float>) {
        let allocator = MTKMeshBufferAllocator(device: renderPacket.device)
        let iomesh = MDLMesh(boxWithExtent: [size.x, size.y, size.z],segments: [1, 1, 1],
                             inwardNormals: false, geometryType: .triangles,
                             allocator: allocator)
//        let iomesh = MDLMesh(sphereWithExtent: [2, 2, 2], 
//                             segments: [20, 20], 
//                             inwardNormals: false, 
//                             geometryType: .triangles, 
//                             allocator: allocator)
        print(iomesh.vertexDescriptor)
        iomesh.vertexDescriptor = MDLVertexDescriptor.defaultVertexDescriptor
        mesh = try! MTKMesh(mesh: iomesh, device: renderPacket.device)
        body = Body(position: .zero, rotation: .zero, scale: .one)
    }
    
}
