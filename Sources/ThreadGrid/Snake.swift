import Induction
import Metal
import CoreStructures
import RenderSetup

extension SIMD3 {
    var s: String { "\(x), \(y), \(z)" }
}

public struct SnakeCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    public static var length: Int { MemoryLayout<SnakeCell3D>.stride }
    
//    var velocity: SIMD2<Float>
//    let info: SIMD2<Float>  
//    var density: Float
//    var cell: Int8 // 0 field, 1 body, 2 head, 3 target
//    let velocityAllow: Bool
    
    var base: SnakeCell3D
    
    var char: Character {
        if base.density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
//    public var description: String { "[\(base.position.x), \(base.position.y)]" }
//    public var description: String { "[\(base.info.x), \(base.info.y), \(base.info.z)]" }
//    public var description: String { String(char) }
//        var description: String { "[\(velocity.x),\(velocity.y), \(char)]" }
//    var description: String { "[\(velocity.x),\(velocity.y); \(char)]" }
    
    public var description: String { "\(base.rem)" }
    
    public var isEmpty: Bool { false }
    public init() {
//        velocity = .zero
//        density = 0.0
//        info = .zero
//        cell = 0
//        velocityAllow = true;
        
        base = SnakeCell3D(position: .zero, velocity: .zero, info: .zero, density: 0, cell: 0, rem: 0, velocityAllow: 1)
        
    }
}

public struct InfoBuffer {
    let width: Int
    var cells: [SIMD4<Float>]
    public let buffer: MTLBuffer
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

public struct SnakeFridge {
    public let width = 8
    public let height = 8
    public let depth = 4
    var headDirection: SIMD3<Float> { didSet { print("head direction: \(headDirection.s)") } }
    public var black: ThreadGridBuffer3D<SnakeCell>
    public var white: ThreadGridBuffer3D<SnakeCell>
    public var debug: ThreadGridBuffer3D<SnakeCell>
    public var infobuffer: InfoBuffer
    public let stencil3x3: Stencil3D 
    let renderPacket: RenderPacket
    public init(packet: RenderPacket) {
        renderPacket = packet
        infobuffer = InfoBuffer(device: packet.device, width: 10)
        black = ThreadGridBuffer3D<SnakeCell>(device: packet.device, width: width, height: height, depth: depth)
        white = ThreadGridBuffer3D<SnakeCell>(device: packet.device, width: width, height: height, depth: depth)
        debug = ThreadGridBuffer3D<SnakeCell>(device: packet.device, width: width, height: height, depth: depth)
        headDirection = [1, 0, 0]
        stencil3x3 = Stencil3D.stencil3x3
        initialSpot()
    }
    public mutating func initialSpot() {
        var cell = SnakeCell()
        
        cell.base.density = 0
        cell.base.velocity = headDirection
        cell.base.rem = 22
        black.grids[0][3][2] = cell
        
        cell.base.density = 1
        cell.base.cell = 1
        black.grids[0][2][2] = cell
        
        cell.base.density = 1
        cell.base.cell = 3
        black.grids[0][1][2] = cell
        
        black.fillBuffer()
        
        copy(from: black, to: white)
        white.unbind()
    }
    
    func copy(from: ThreadGridBuffer3D<SnakeCell>, to: ThreadGridBuffer3D<SnakeCell>) {
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
    let clearState: MTLComputePipelineState
    let captureState: MTLComputePipelineState
    let copyState: MTLComputePipelineState
    let fillTextureState: MTLComputePipelineState
    let setVelocityState: MTLComputePipelineState
    let advectContentState: MTLComputePipelineState
    var iterations = 0
    
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        fridge = SnakeFridge(packet: renderPacket)
        texture = AdvectRenderer.makeTexture(view: metalView, 
                                             size: [fridge.width, fridge.height], 
                                             device: renderPacket.device, scale: 6)!
        metalView.framebufferOnly = false
        var function = renderPacket.library.makeFunction(name: "fillSnakeTextureToDark")!
        clearTextureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "unitAdvectVelocitySnake3DE")!
        advectState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "fillSnakeTexture")!
        fillTextureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "setHeadVelocityE")!
        setVelocityState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "captureSnake")!
        captureState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "copySnake")!
        copyState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "cleanFieldSnake3D")!
        clearState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "contentAdvectSnake3DE")!
        advectContentState = try! renderPacket.device.makeComputePipelineState(function: function)
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
        var cell = fridge.black.grids[0][x][y]
        cell.base.density = 1.0
        fridge.black.grids[0][x][y] = cell
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
        let threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, fridge.depth)
        commandEncoder.setComputePipelineState(setVelocityState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        let forcePass = [fridge.headDirection]
        var length = MemoryLayout<SIMD3<Float>>.stride * 1
        commandEncoder.setBytes(forcePass, length: length, index: 1)
        let last = [UInt32(22 + 10 * iterations)]
        length = MemoryLayout<UInt32>.stride * 1
        commandEncoder.setBytes(last, length: length, index: 2)
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
    }
    
    public func draw(in view: MTKView) {
        
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
        commandEncoder.setBytes([fridge.stencil3x3.cStencil], length: fridge.stencil3x3.length, index: 2)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, fridge.depth)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        width = advectContentState.threadExecutionWidth
        height = advectContentState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(advectContentState)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0) 
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 1) 
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, fridge.depth)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        width = clearState.threadExecutionWidth
        height = clearState.maxTotalThreadsPerThreadgroup / width
        commandEncoder.setComputePipelineState(clearState)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0) 
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 1) 
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, fridge.depth)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
//        width = copyState.threadExecutionWidth
//        height = copyState.maxTotalThreadsPerThreadgroup / width
//        commandEncoder.setComputePipelineState(copyState)
//        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0) // source
//        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 1) // target
//        threadsPerGroup = MTLSizeMake(width, height, 1)
//        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, fridge.depth)
//        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
//        width = captureState.threadExecutionWidth
//        height = captureState.maxTotalThreadsPerThreadgroup / width
//        commandEncoder.setComputePipelineState(captureState)
//        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
//        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1)
//        commandEncoder.setBytes([fridge.stencil3x3.cStencil], length: fridge.stencil3x3.length, index: 2)
//        threadsPerGroup = MTLSizeMake(width, height, 1)
//        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, fridge.depth)
//        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        
        commandEncoder.setComputePipelineState(fillTextureState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        commandEncoder.setTexture(texture, index: 0)
        threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
        blitEncoder.copy(from: fridge.black.buffer, 
                         sourceOffset: 0, 
                         to: fridge.white.buffer, 
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
        
        iterations += 1
        print("last header: \(22 + 10 * iterations)")
        fridge.renderBlackWhite()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
