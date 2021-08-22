#if os(macOS)
import MetalKit
import Draw
import App

@available(OSX 10.11, *)
public struct SnakeCook {
    
    public init() {}
    
    public func prepareDraw() -> ControllerPacket {
        
        /// Вызывается в методе вью контроллера
        func initialdraw() -> (viewsWindowOne: [NSView], viewsWindowTwo: [NSView], viewsWindowThree: [NSView], stored: [Any]) {
            
            let canvas = Canvas(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
            canvas.backcolor = Color.brown.cgcolor
            
            
            let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
            metalView.preferredFramesPerSecond = 60
            metalView.enableSetNeedsDisplay = true
            metalView.isPaused = true
            let cc = SIMD3<Double>(Color.darkbrown.simd3)
            metalView.clearColor = MTLClearColor(red: cc.x, green: cc.y, blue: cc.z, alpha: 1)
            
            canvas.addSubview(metalView)
            let defaultDevice = MTLCreateSystemDefaultDevice()!
            metalView.device = defaultDevice
            let renderer = Renderer(metalView: metalView)
            metalView.delegate = renderer
            
            
            
            canvas.mousedrug = { point in
                renderer.mouseDrug(at: point)
                metalView.setNeedsDisplay(canvas.bounds)
            }
            
            canvas.mousedown = { point in renderer.mouseDown(at: point) }
            canvas.mouseup = { point in renderer.mouseUp(at: point)  }
            
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (e) -> NSEvent? in
                return e
            }
            
            
            defer {
                command(renderer: renderer, metalView: metalView, canvas: canvas)
            }
            
            return ([canvas], [], [], [1])
        }
        
        
        /// Вызывается в методе вью контроллера
        func system(a: Int) {}
        
        
        let packet = ControllerPacket(initialClosure: initialdraw, systemCallClosure: system)
        return packet
    }
    
    func command(renderer: Renderer, metalView: MTKView, canvas: NSView) {
        DispatchQueue.global().async {
            var command = ""
            while command != "end" {
                print("input command:")
                guard let line = readLine() else { continue }
                switch line {
                default: break
                }
                command = line
                print("command: \(command)")
            }
            print("end commands")
        }
    }
    
}
#endif

