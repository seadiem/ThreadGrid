import Metal
import Files

public struct RenderPacket {
    
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let library: MTLLibrary
    
    public init() {
    
        let device = MTLCreateSystemDefaultDevice()!
        let commandQueue = device.makeCommandQueue()!
        
        #if os(macOS)
        let path = "/Users/oktet/Code/Learn/Shaders/Shaders/Shaders"
        let folder = try! Folder(path: path)
        var shader = ""
        for file in folder.files {
            guard file.name == "Grid1.metal" || 
                    file.name == "Fluids.metal" || 
                    file.name == "Move.metal" ||
                    file.name == "Advection.metal" ||
                    file.name == "Debug.metal" ||
                    file.name == "Snake.metal" ||
                    file.name == "SnakeRender.metal"
            else { continue }
            guard let content = try? file.readAsString() else { continue }
            shader += content
        }
        let library = try! device.makeLibrary(source: shader, options: nil)
        #else
        let library = device.makeDefaultLibrary()!
        #endif
        
        self.device = device
        self.commandQueue = commandQueue
        self.library = library

    }
    
}
