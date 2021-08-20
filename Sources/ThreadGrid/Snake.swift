import Induction
import Metal
import CoreStructures
import RenderSetup

struct SnakeCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    static var length: Int { MemoryLayout<SnakeCellC>.stride }
    
//    var velocity: SIMD2<Float>
//    let info: SIMD2<Float>  
//    var density: Float
//    var cell: Int8 // 0 field, 1 body, 2 head, 3 target
//    let velocityAllow: Bool
    
    var base: SnakeCellC
    
    var char: Character {
        if base.density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
//        var description: String { "[\(info.x), \(info.y)]" }
    //    var description: String { String(char) }
//        var description: String { "[\(velocity.x),\(velocity.y), \(char)]" }
//    var description: String { "[\(velocity.x),\(velocity.y); \(char)]" }
    var description: String { 
        var out = "" 
        if "\(base.density)".count == 3 {
            out = "0"
        }
        out = "\(base.density)" + out
//        return out
        return "[\(base.velocity.x),\(base.velocity.y), \(out), \(base.cell)]" 
    }
    var isEmpty: Bool { false }
    init() {
//        velocity = .zero
//        density = 0.0
//        info = .zero
//        cell = 0
//        velocityAllow = true;
        
        base = SnakeCellC(velocity: .zero, info: .zero, density: 0, cell: 0, velocityAllow: 1)
        
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
    let width = 9
    let height = 9
    var headDirection: SIMD2<Float> 
    var black: ThreadGrid<SnakeCell>
    var white: ThreadGrid<SnakeCell>
    var debug1: ThreadGrid<SnakeCell>
    var debug2: ThreadGrid<SnakeCell>
    var debug3: ThreadGrid<SnakeCell>
    var infobuffer: InfoBuffer
    let renderPacket: RenderPacket
    init(packet: RenderPacket) {
        renderPacket = packet
        infobuffer = InfoBuffer(device: packet.device, width: 10)
        black = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        white = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        debug1 = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        debug2 = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        debug3 = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        headDirection = .zero
        initialSpot()
    }
    mutating func initialSpot() {
        var cell = SnakeCell()
        
        cell.base.density = 1.0
        cell.base.velocity = [1.0, 0.0]
        cell.base.cell = 2
        black.columns[3][2] = cell
        
        cell.base.density = 1
        cell.base.cell = 1
        black.columns[2][2] = cell
        
        cell.base.density = 0
        cell.base.cell = 0
        black.columns[1][2] = cell
        
        cell.base.density = 1.0
        cell.base.cell = 3
        cell.base.velocity = .zero
        black.columns[5][5] = cell
        black.columns[2][5] = cell
        
        black.fillBuffer()
        
        copy(from: black, to: white)
        white.unbind()
        print("initial")
        renderBlackWhite()
    }
    
    func copy(from: ThreadGrid<SnakeCell>, to: ThreadGrid<SnakeCell>) {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: from.buffer, 
                         sourceOffset: 0, 
                         to: to.buffer, 
                         destinationOffset: 0, 
                         size: from.biteSize)
        blitEncoder.endEncoding()
        commandBuffer.commit()
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
        print("- white")
        white.unbind()
        white.render()
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
    let captureState: MTLComputePipelineState
    let copyState: MTLComputePipelineState
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
        function = renderPacket.library.makeFunction(name: "captureSnake")!
        captureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "copySnake")!
        copyState = try! renderPacket.device.makeComputePipelineState(function: function)
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
    func tapAt(x: Int, y: Int) {
        print("taped at: \(x), \(y)")
        fridge.black.unbind()
        fridge.white.unbind()
        var cell = fridge.black.columns[x][y]
        cell.base.density = 1.0
        fridge.black.columns[x][y] = cell
        fridge.black.fillBuffer()
        fridge.copy(from: fridge.black, to: fridge.white)
        fridge.white.unbind()
        fridge.renderBlackWhite()
    }
    func setVelocity() {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
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
        
        width = copyState.threadExecutionWidth
        height = copyState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(copyState)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0) // source
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 1) // target
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        width = captureState.threadExecutionWidth
        height = captureState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(captureState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1)
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
