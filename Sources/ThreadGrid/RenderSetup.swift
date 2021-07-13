import Metal
import Files

struct RenderPacket {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let library: MTLLibrary
    
    init() {
    
        let device = MTLCreateSystemDefaultDevice()!
        let commandQueue = device.makeCommandQueue()!
        
        #if os(macOS)
        let path = "/Users/oktet/Code/Learn/Shaders/Shaders/Shaders"
        let folder = try! Folder(path: path)
        var shader = ""
        for file in folder.files {
            guard file.name == "Grid1.metal" else { continue }
            guard let content = try? file.readAsString() else { continue }
            shader = content
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
