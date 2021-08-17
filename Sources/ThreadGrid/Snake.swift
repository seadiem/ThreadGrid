import Induction
import Metal

struct SnakeCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    static var length: Int { MemoryLayout<SnakeCell>.stride }
    
    var velocity: SIMD2<Float>
    let info: SIMD2<Float>  
    var density: Float
    var cell: Int8 // 0 field, 1 body, 2 target. 
    let velocityAllow: Bool
    
    var char: Character {
        if density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
//        var description: String { "[\(info.x), \(info.y)]" }
    //    var description: String { String(char) }
//        var description: String { "[\(velocity.x),\(velocity.y), \(char)]" }
//    var description: String { "[\(velocity.x),\(velocity.y); \(char)]" }
    var description: String { 
        var out = "" 
        if "\(density)".count == 3 {
            out = "0"
        }
        out = "\(density)" + out
//        return out
        return "[\(velocity.x),\(velocity.y), \(out)]" 
    }
    var isEmpty: Bool { false }
    init() {
        velocity = .zero
        density = 0.0
        info = .zero
        cell = 0
        velocityAllow = true;
    }
}


struct InfoBuffer {
    let width: Int
    var cells: [SIMD4<Float>]
    let buffer: MTLBuffer
    var tempStorage: [SIMD4<Float>]
    init(device: MTLDevice, width: Int) {
        self.width = width
        self.cells = Array(repeating: .zero, count: width)
        buffer = device.makeBuffer(length: width * MemoryLayout<SIMD4<Float>>.stride, options: .storageModeShared)!
        tempStorage = cells
    }
    mutating func unbind() {        
        let result = buffer.contents().bindMemory(to: SIMD4<Float>.self, capacity: width)
        for i in tempStorage.indices { tempStorage[i] = result[i] }
        cells = tempStorage
    }
    mutating func render() {
        unbind()
        let z = cells.map { "[\($0.x),\($0.y)]" }
        print("info: \(z)")
    }
}

struct SnakeFridge {
    let width = 8
    let height = 8
    var headDirection: SIMD2<Float> 
    var black: ThreadGrid<SnakeCell>
    var white: ThreadGrid<SnakeCell>
    var debug1: ThreadGrid<SnakeCell>
    var debug2: ThreadGrid<SnakeCell>
    var debug3: ThreadGrid<SnakeCell>
    var infobuffer: InfoBuffer
    init(packet: RenderPacket) {
        infobuffer = InfoBuffer(device: packet.device, width: 10)
        black = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        white = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        debug1 = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        debug2 = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        debug3 = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        headDirection = .zero
        touchSpot()
    }
    mutating func touchSpot() {
        
        var cell = SnakeCell()
        cell.density = 1.0
        cell.velocity = [1.0, 0.0]
        cell.cell = 1
        
        black.columns[3][2] = cell
        white.columns[3][2] = cell
        
        cell.density = 0
        cell.cell = 0
        black.columns[2][2] = cell
        white.columns[2][2] = cell
//        cell.velocity = .zero
//        cell.cell = 2
//        black.columns[5][5] = cell
//        white.columns[5][5] = cell
        
        black.fillBuffer()
        white.fillBuffer()
    }
    mutating func renderSubtraction() {
//        print("- black")
//        debug3.unbind()
//        debug3.render()
//        print("- white")
//        debug2.unbind()
//        debug2.render()
//        print("- white +")
//        debug1.unbind()
//        debug1.render()
//        print("- уменьшаемое")
//        debug1.unbind()
//        debug1.render()
//        print("- вычитаемое")
//        debug2.unbind()
//        debug2.render()
//        print("- разность")
//        white.unbind()
//        white.render()
    }
    mutating func renderBlackWhite() {
//        print("- white")
//        white.unbind()
//        white.render()
        print("- black")
        black.unbind()
        black.render()
    }
}



import MetalKit
class SnakeRenderer: NSObject, MTKViewDelegate  {
    
    var fridge: SnakeFridge
    let renderPacket: RenderPacket
    let texture: MTLTexture
    let clearTextureState: MTLComputePipelineState
    let advectState: MTLComputePipelineState
    let diffState: MTLComputePipelineState
    let swapHeadState: MTLComputePipelineState
    let fillTextureState: MTLComputePipelineState
    let setVelocityState: MTLComputePipelineState
    
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        fridge = SnakeFridge(packet: renderPacket)
        texture = AdvectRenderer.makeTexture(view: metalView, 
                                             size: [fridge.width, fridge.height], 
                                             device: renderPacket.device, scale: 6)!
        metalView.framebufferOnly = false
        var function = renderPacket.library.makeFunction(name: "fillSnakeTextureToDark")!
        clearTextureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "unitAdvectVelocitySnake")!
        advectState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "fillSnakeTexture")!
        fillTextureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "setHeadVelocity")!
        setVelocityState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "diffSnake")!
        diffState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "swapSnake")!
        swapHeadState = try! renderPacket.device.makeComputePipelineState(function: function)
        super.init()
        print("render initial")
        fridge.renderBlackWhite()
    }
    static func makeTexture(view: MTKView, size: SIMD2<Int>, device: MTLDevice, scale: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, 
                                                                  width: size.x * scale, 
                                                                  height: size.y * scale, 
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
    func setVelocity() {
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        let width = setVelocityState.threadExecutionWidth
        let height = setVelocityState.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.setComputePipelineState(setVelocityState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        let forcePass = [fridge.headDirection]
        let length = MemoryLayout<SIMD2<Float>>.stride * 1
        commandEncoder.setBytes(forcePass, length: length, index: 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: fridge.black.buffer, 
                         sourceOffset: 0, 
                         to: fridge.white.buffer, 
                         destinationOffset: 0, 
                         size: fridge.white.biteSize)
        blitEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        print("force passed: \(forcePass)")
        fridge.renderBlackWhite()
    }
    
    public func draw(in view: MTKView) {
        
        print("draw")
        
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        var width = clearTextureState.threadExecutionWidth
        var height = clearTextureState.maxTotalThreadsPerThreadgroup / width
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        commandEncoder.setComputePipelineState(clearTextureState)
        commandEncoder.setTexture(view.currentDrawable!.texture, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        width = advectState.threadExecutionWidth
        height = advectState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(advectState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0) // From
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1) // To
        commandEncoder.setBuffer(fridge.infobuffer.buffer, offset: 0, index: 2)
        commandEncoder.setBuffer(fridge.debug3.buffer, offset: 0, index: 3) 
        commandEncoder.setBuffer(fridge.debug2.buffer, offset: 0, index: 4)
        commandEncoder.setBuffer(fridge.debug1.buffer, offset: 0, index: 5)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(diffState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0) // вычитаемое
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1) // уменьшаемое
        commandEncoder.setBuffer(fridge.infobuffer.buffer, offset: 0, index: 2)
        commandEncoder.setBuffer(fridge.debug1.buffer, offset: 0, index: 3)
        commandEncoder.setBuffer(fridge.debug2.buffer, offset: 0, index: 4)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(fillTextureState)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0)
        commandEncoder.setTexture(texture, index: 0)
        threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: fridge.white.buffer, 
                         sourceOffset: 0, 
                         to: fridge.black.buffer, 
                         destinationOffset: 0, 
                         size: fridge.white.biteSize)
        
        let origin = MTLOriginMake(0, 0, 0)
        let size = MTLSizeMake(texture.width, texture.height, 1)
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: origin, sourceSize: size,
                         to: view.currentDrawable!.texture, destinationSlice: 0,
                         destinationLevel: 0, destinationOrigin: origin)
        blitEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        print("")
 //       fridge.renderSubtraction()
        fridge.renderBlackWhite()
 //       fridge.infobuffer.render()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
