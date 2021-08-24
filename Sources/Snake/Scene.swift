import RenderSetup
import Metal
import CoreStructures
import simd

class Scene {
    
    let coub: Coub
    var camera: Camera
    
    init(renderPacket: RenderPacket) {
        coub = Coub(renderPacket: renderPacket, size: [5, 5, 5])
        camera = Camera(position: [0, 0, -10])
    }
    
    func draw(into renderEncoder: MTLRenderCommandEncoder) {
        
        renderEncoder.setVertexBuffer(coub.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        let uniforms = RazewareUniforms(modelMatrix: coub.body.modelMatrix, 
                                        viewMatrix: camera.viewMatrix, 
                                        projectionMatrix: camera.projectionMatrix, 
                                        normalMatrix: coub.body.modelMatrix.upperLeft)
        
        let outuniforms = [uniforms]
        renderEncoder.setVertexBytes(outuniforms, length: MemoryLayout<RazewareUniforms>.stride * 1, index: 1)
        
        let matricies = [camera.projectionMatrix, camera.viewMatrix, camera.body.modelMatrix * coub.body.modelMatrix]
        renderEncoder.setVertexBytes(matricies, length: MemoryLayout<simd_float4x4>.stride * matricies.count, index: 2)
        
        let fragmentUniform = FragmentUniforms(lightCount: 1, cameraPosition: camera.body.position)
        let outfragments = [fragmentUniform]
        renderEncoder.setFragmentBytes(outfragments, length:  MemoryLayout<FragmentUniforms>.stride * 1, index: 1)
        
        coub.mesh.submeshes.forEach {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: $0.indexCount,
                                                indexType: $0.indexType,
                                                indexBuffer: $0.indexBuffer.buffer,
                                                indexBufferOffset: $0.indexBuffer.offset)
        }
    }
}