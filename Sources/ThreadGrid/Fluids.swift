import Metal
import Induction
import RenderSetup

struct FluidCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    static var length: Int { MemoryLayout<FluidCell>.stride }
    var density: Float
    var velocity: SIMD2<Float>
    let temp: SIMD2<Float> = .zero
    var char: Character {
        if density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
//    var description: String { "[\(temp.x), \(temp.y)]" }
//    var description: String { String(char) }
//    var description: String { "[\(temp.x),\(temp.y)]" }
//    var description: String { "[\(velocity.x),\(velocity.y)]" }
    var description: String { "[\(velocity.x),\(velocity.y); \(char)]" }
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
        velocity = [1.0, 0.0]
        density = 0.0
    }
}

struct FluidFridge {
    enum State { 
        case black, white
        mutating func further() {
            switch self {
            case .black: self = .white
            case .white: self = .black
            }
        }
    }
    let width = 9
    let height = 9
    var black: ThreadGridBuffer<FluidCell>
    var white: ThreadGridBuffer<FluidCell>
    var state: State
    var current: ThreadGridBuffer<FluidCell> {
        switch state {
        case .black: return black
        case .white: return white
        }
    }
    var next: ThreadGridBuffer<FluidCell> {
        switch state {
        case .black: return white
        case .white: return black
        }
    }
    init(packet: RenderPacket) {
        black = ThreadGridBuffer<FluidCell>(device: packet.device, width: width, height: height)
        white = ThreadGridBuffer<FluidCell>(device: packet.device, width: width, height: height)
        state = .black
        touchSpot()
//        touchBigSpot()
    }
    mutating func touchSpot() {
        black.columns[1][0].density = 1.0
        black.fillBuffer()
    }
    mutating func touchBigSpot() {
        black.columns[2][2].density = 1.0
        black.columns[2][3].density = 1.0
        black.columns[2][4].density = 1.0
        black.columns[2][5].density = 1.0
        black.columns[3][2].density = 1.0
        black.columns[3][3].density = 1.0
        black.columns[3][4].density = 1.0
        black.columns[3][5].density = 1.0
        black.columns[4][2].density = 1.0
        black.columns[4][3].density = 1.0
        black.columns[4][4].density = 1.0
        black.columns[4][5].density = 1.0
        black.columns[5][2].density = 1.0
        black.columns[5][3].density = 1.0
        black.columns[5][4].density = 1.0
        black.columns[5][5].density = 1.0
        black.fillBuffer()
    }
    mutating func further() {
        state.further()
    }
    mutating func noPassRender() {
        black.unbind()
        black.render()
    }
    mutating func renderBlackWhite() {
        print("black")
        black.unbind()
        black.render()
        print("white")
        white.unbind()
        white.render()
    }
}

import MetalKit
class AdvectRenderer: NSObject, MTKViewDelegate  {
    
    let renderPacket: RenderPacket
    var fridge: FluidFridge
    var texture: MTLTexture
    
    let zeroState: MTLComputePipelineState
    let boundState: MTLComputePipelineState
    let firstState: MTLComputePipelineState
    let lastState: MTLComputePipelineState
    
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        fridge = FluidFridge(packet: renderPacket)
        texture = AdvectRenderer.makeTexture(view: metalView, 
                                             size: [fridge.width, fridge.height], 
                                             device: renderPacket.device, scale: 2)!
        metalView.framebufferOnly = false
        var function = renderPacket.library.makeFunction(name: "fillTextureToDark")!
        zeroState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "advectK1_3")!
        firstState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "fillTexture")!
        lastState = try! renderPacket.device.makeComputePipelineState(function: function)
        function = renderPacket.library.makeFunction(name: "bounds")!
        boundState = try! renderPacket.device.makeComputePipelineState(function: function)
        super.init()
    }
    deinit {
        print("deinit")
    }
    func sort() {
        print("sort")
    }
    static func makeTexture(view: MTKView, size: SIMD2<Int>, device: MTLDevice, scale: Int) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: view.colorPixelFormat, 
                                                                  width: size.x * scale, 
                                                                  height: size.y * scale, 
                                                                  mipmapped: false)
        descriptor.usage = [.shaderRead, .shaderWrite]
        return device.makeTexture(descriptor: descriptor)
    }
    func set(point: SIMD2<Float>) {
        //        self.point.position = point
    }
    public func draw(in view: MTKView) {
        
        guard let commandBuffer = renderPacket.commandQueue.makeCommandBuffer(),
              let commandEncoder = commandBuffer.makeComputeCommandEncoder(),
              let drawable = view.currentDrawable else {
            return
        }
        
        let width = firstState.threadExecutionWidth
        let height = firstState.maxTotalThreadsPerThreadgroup / width
        var threadsPerGroup = MTLSizeMake(width, height, 1)
        var threadsPerGrid = MTLSizeMake(Int(view.drawableSize.width), Int(view.drawableSize.height), 1)
        
        commandEncoder.setComputePipelineState(zeroState)
        commandEncoder.setTexture(drawable.texture, index: 0)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(boundState)
        commandEncoder.setBuffer(fridge.next.buffer, offset: 0, index: 0)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(boundState)
        commandEncoder.setBuffer(fridge.current.buffer, offset: 0, index: 0)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(firstState)
        commandEncoder.setBuffer(fridge.current.buffer, offset: 0, index: 0)
        commandEncoder.setBuffer(fridge.next.buffer, offset: 0, index: 1)
        threadsPerGroup = MTLSizeMake(width, height, 1)
        threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        
        commandEncoder.setComputePipelineState(lastState)
        commandEncoder.setBuffer(fridge.next.buffer, offset: 0, index: 0)
        commandEncoder.setTexture(texture, index: 0)
        threadsPerGrid = MTLSizeMake(texture.width, texture.height, 1)
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
        fridge.further()
        fridge.renderBlackWhite()
        print("-")
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}

struct FluidQuickPass {
    let renderPacket: RenderPacket
    let state: MTLComputePipelineState
    var fridge: FluidFridge
    init() {
        renderPacket = RenderPacket()        
        let library = renderPacket.library
        let function = library.makeFunction(name: "moveCellsPrecise")!
        state = try! renderPacket.device.makeComputePipelineState(function: function)
        fridge = FluidFridge(packet: renderPacket)
    }
    func pass() {
        let commandBuffer = renderPacket.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(state)
        commandEncoder.setBuffer(fridge.current.buffer, offset: 0, index: 0)
        commandEncoder.setBuffer(fridge.next.buffer, offset: 0, index: 1)
        let width = state.threadExecutionWidth
        let height = state.maxTotalThreadsPerThreadgroup / width
        let threadsPerGroup = MTLSizeMake(height, height, 1)
        let threadsPerGrid = MTLSizeMake(fridge.width, fridge.height, 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    mutating func further() {
        fridge.further()
    }
    var count = 0
    mutating func render() {
        print("RENDER: \(count)")
        fridge.white.unbind()
        fridge.black.unbind()
        fridge.current.render()
        count += 1
    }
}


