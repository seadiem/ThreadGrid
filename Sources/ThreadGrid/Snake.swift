import Induction
import Metal

struct SnakeCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    static var length: Int { MemoryLayout<FluidCell>.stride }
    var head: Int16
    var tail: Bool
    var number: Int16
    var density: Float
    var velocity: SIMD2<Float>
    let temp: SIMD2<Float> = .zero
    var char: Character {
        if density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
    var description: String { "\(head)"}
    //    var description: String { "[\(temp.x), \(temp.y)]" }
    //    var description: String { String(char) }
//        var description: String { "[\(velocity.x),\(velocity.y)]" }
//    var description: String { "[\(velocity.x),\(velocity.y); \(char)]" }
//    var description: String { 
//        var out = "" 
//        if "\(density)".count == 3 {
//            out = "0"
//        }
//        out = "\(density)" + out
//        return out
//    }
    var isEmpty: Bool { false }
    init() {
        velocity = .zero
        density = 0.0
        number = 0
        head = 0
        tail = false
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
    var infobuffer: InfoBuffer
    init(packet: RenderPacket) {
        infobuffer = InfoBuffer(device: packet.device, width: 10)
        black = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        white = ThreadGrid<SnakeCell>(device: packet.device, width: width, height: height)
        headDirection = .zero
        touchSpot()
    }
    mutating func touchSpot() {
        
        var cell = SnakeCell()
        cell.head = 1
        cell.tail = false
        cell.density = 1.0
        cell.velocity = [1.0, 0.0]
        
        
        black.columns[2][2] = cell
        white.columns[2][2] = cell
        
//        cell.head = true
//        cell.tail = false
//        cell.density = 1.0
//        cell.velocity = [0.0, 0.0]
//        
//        black.columns[1][2] = cell
//        white.columns[1][2] = cell
        
        black.fillBuffer()
        white.fillBuffer()
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
    let zeroState: MTLComputePipelineState
    let advectState: MTLComputePipelineState
    let copyState: MTLComputePipelineState
    let diffState: MTLComputePipelineState
    let lastState: MTLComputePipelineState
    let setVelocityState: MTLComputePipelineState
    
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        fridge = SnakeFridge(packet: renderPacket)
        texture = AdvectRenderer.makeTexture(view: metalView, 
                                             size: [fridge.width, fridge.height], 
                                             device: renderPacket.device, scale: 6)!
        metalView.framebufferOnly = false
        var function = renderPacket.library.makeFunction(name: "fillSnakeTextureToDark")!
        zeroState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "unitAdvectVelocitySnake")!
        advectState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "fillSnakeTexture")!
        lastState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "setHeadVelocity")!
        setVelocityState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "copySnake")!
        copyState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "diffSnake")!
        diffState = try! renderPacket.device.makeComputePipelineState(function: function)
        super.init()
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
        print("pass")
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        else { return }
        let width = zeroState.threadExecutionWidth
        let height = zeroState.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(width, height, 1)
        let threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.setComputePipelineState(setVelocityState)
        // black
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        let forcePass = [fridge.headDirection]
        let length = MemoryLayout<SIMD2<Float>>.stride * 1
        commandEncoder.setBytes(forcePass, length: length, index: 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        // white
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0)
        commandEncoder.setBytes(forcePass, length: length, index: 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    public func draw(in view: MTKView) {
        
        print("draw")
        
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        
        
        let width = zeroState.threadExecutionWidth
        let height = zeroState.maxTotalThreadsPerThreadgroup / width
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        commandEncoder.setComputePipelineState(zeroState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(advectState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0) // From
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1) // To
        commandEncoder.setBuffer(fridge.infobuffer.buffer, offset: 0, index: 2)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        
        commandEncoder.setComputePipelineState(diffState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0) 
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 1) 
        commandEncoder.setBuffer(fridge.infobuffer.buffer, offset: 0, index: 2)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(copyState)
        commandEncoder.setBuffer(fridge.white.buffer, offset: 0, index: 0) // From
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 1) // To
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(lastState)
        commandEncoder.setBuffer(fridge.black.buffer, offset: 0, index: 0)
        commandEncoder.setTexture(texture, index: 0)
        threadsPerGrid = MTLSizeMake(texture.width * 2, texture.height * 2, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.endEncoding()
        
        guard let blitEncoder = commandBuffer.makeBlitCommandEncoder() else {return }
        let origin = MTLOriginMake(0, 0, 0)
        let size = MTLSizeMake(texture.width, texture.height, 1)
        blitEncoder.copy(from: texture, sourceSlice: 0, sourceLevel: 0,
                         sourceOrigin: origin, sourceSize: size,
                         to: drawable.texture, destinationSlice: 0,
                         destinationLevel: 0, destinationOrigin: origin)
        blitEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        fridge.renderBlackWhite()
        fridge.infobuffer.render()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}
