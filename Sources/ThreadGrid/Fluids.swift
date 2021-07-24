import Metal
import Induction

struct FluidCell: CustomStringConvertible, EmptyInit, LengthSupplier {
    static var length: Int { MemoryLayout<FluidCell>.stride }
    let temp: SIMD2<Float> = .zero
    var velocity: SIMD2<Float>
    var density: Float
    var char: Character {
        if density > 0.5 { return "◼︎" }
        else { return "◻︎" }
    }
//    var description: String { "[\(temp.x), \(temp.y)]" }
    var description: String { String(char) }
//    var description: String { "[\(velocity.x), \(velocity.y)]" }
//    var description: String { "[\(density)]" }
    var isEmpty: Bool { false }
    init() {
        velocity = .zero
        density = 0
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
    let width = 8
    let height = 3
    var black: ThreadGrid<FluidCell>
    var white: ThreadGrid<FluidCell>
    var state: State
    var current: ThreadGrid<FluidCell> {
        switch state {
        case .black: return black
        case .white: return white
        }
    }
    var next: ThreadGrid<FluidCell> {
        switch state {
        case .black: return white
        case .white: return black
        }
    }
    init(packet: RenderPacket) {
        black = ThreadGrid<FluidCell>(device: packet.device, width: width, height: height)
        white = ThreadGrid<FluidCell>(device: packet.device, width: width, height: height)
        state = .black
    }
    mutating func further() {
        state.further()
    }
    mutating func noPassRender() {
        black.unbind()
        black.render()
    }
    func render() {
        next.render()
//        print("black")
//        black.render()
//        print("white")
//        white.render()
    }
}
import MetalKit
class AdvectRenderer: NSObject, MTKViewDelegate  {
    let renderPacket: RenderPacket
    public init(metalView: MTKView) {
        renderPacket = RenderPacket()
        super.init()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    public func draw(in view: MTKView) {}
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
        fridge.render()
        count += 1
    }
}


