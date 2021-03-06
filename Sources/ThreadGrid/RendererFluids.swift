import MetalKit
import MetalPerformanceShaders
import RenderSetup

public class RendererFluids: NSObject {
    
    var point: Butterfly
    var buffer: RowBuffer
    
    let renderPacket: RenderPacket
    let firstState: MTLComputePipelineState
    let secondState: MTLComputePipelineState
    
    let currentDrawed: MTLTexture
    let firstTexture: MTLTexture
    let secondTexture: MTLTexture
    let thirdTexture: MTLTexture
    
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        buffer = RowBuffer(packet: renderPacket)
        let position: SIMD2<Float> = [100, 50]
        point = Butterfly(id: 0, position: position, velocity: .zero)
        
        metalView.framebufferOnly = false
        
        let library = renderPacket.library
        let firstPass = library.makeFunction(name: "backgroundDraw")!
        firstState = try! renderPacket.device.makeComputePipelineState(function: firstPass)
        
        let secondPass = library.makeFunction(name: "lightDraw")!
        secondState = try! renderPacket.device.makeComputePipelineState(function: secondPass)
        
        currentDrawed = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        firstTexture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        secondTexture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        thirdTexture = RendererLights.makeTexture(view: metalView, device: renderPacket.device)!
        
        super.init()
    }
    
    static func makeTexture(view: MTKView, device: MTLDevice) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, 
                                                                  width: Int(view.bounds.width), 
                                                                  height: Int(view.bounds.height), 
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
    
}

extension RendererFluids: MTKViewDelegate {
    public func draw(in view: MTKView) {
        
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        
        let width = firstState.threadExecutionWidth
        let height = firstState.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        
        
        // first pass
        commandEncoder.setComputePipelineState(firstState)
        commandEncoder.setTexture(currentDrawed, index: 0)
        commandEncoder.setTexture(firstTexture, index: 1)
        commandEncoder.setBuffer(buffer.buffer, offset: 0, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // buffer to texture
        let points = [point]
        let length = MemoryLayout<Butterfly>.stride * points.count
        commandEncoder.setComputePipelineState(secondState)
        commandEncoder.setTexture(secondTexture, index: 0)
        commandEncoder.setTexture(firstTexture, index: 1)
        commandEncoder.setBytes(points, length: length, index: 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        // end encoding pass
        commandEncoder.endEncoding()
        
        // blit encoder
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {return }
        let origin = MTLOriginMake(0, 0, 0)
        let size = MTLSizeMake(drawable.texture.width, drawable.texture.height, 1)
        blitEncoder.copy(from: secondTexture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: origin, sourceSize: size,
                         to: currentDrawed, destinationSlice: 0,
                         destinationLevel: 0, destinationOrigin: origin)
        blitEncoder.copy(from: currentDrawed, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: origin, sourceSize: size,
                         to: drawable.texture, destinationSlice: 0,
                         destinationLevel: 0, destinationOrigin: origin)
        blitEncoder.endEncoding()
        
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

public extension RendererFluids {
    func set(point: SIMD2<Float>) {
        self.point.position = point
    }
}

