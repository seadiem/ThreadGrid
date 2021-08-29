import RenderSetup
import Metal
import CoreStructures
import simd
import ThreadGrid

class Scene {
    
    let coub: Coub
    var fridge: Fridge
    var camera: Camera
    var white: ThreadGridBuffer<SnakeCell>?
    
    init(renderPacket: RenderPacket) {
        fridge = Fridge()
        coub = Coub(renderPacket: renderPacket, size: [4.98, 4.98, 4.98])
        camera = Camera(position: [0, 0, -20])
    }
    
    func draw(into renderEncoder: MTLRenderCommandEncoder) {
        
        guard let white = white else { return }
        
        renderEncoder.setVertexBuffer(coub.mesh.vertexBuffers[0].buffer, offset: 0, index: 0)
        
        let uniforms = SnakeFridgeUniforms(fridgeNormalMatrix: fridge.body.modelMatrix.upperLeft, 
                                           fridgeModelMatrix: fridge.body.modelMatrix, 
                                           cameraModelMatrix: camera.viewMatrix, 
                                           cameraProjectionMatrix: camera.projectionMatrix)
        let outuniforms = [uniforms]
        
        renderEncoder.setVertexBytes(outuniforms, length: MemoryLayout<SnakeFridgeUniforms>.stride * 1, index: 1)
        renderEncoder.setVertexBytes(fridge.transforms, length:  MemoryLayout<CoubeTransform>.stride * fridge.transforms.count, index: 2)
        renderEncoder.setVertexBuffer(white.buffer, offset: 0, index: 3)
        
        let fragmentUniform = FragmentUniforms(lightCount: 1, cameraPosition: camera.body.position)
        let outfragments = [fragmentUniform]
        renderEncoder.setFragmentBytes(outfragments, length:  MemoryLayout<FragmentUniforms>.stride * 1, index: 1)
        
        coub.mesh.submeshes.forEach {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: $0.indexCount,
                                                indexType: $0.indexType,
                                                indexBuffer: $0.indexBuffer.buffer,
                                                indexBufferOffset: $0.indexBuffer.offset,
                                                instanceCount:  white.biteSize)
        }
    }
}
