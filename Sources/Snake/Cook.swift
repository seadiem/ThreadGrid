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
            canvas.addSubview(metalView)
            let defaultDevice = MTLCreateSystemDefaultDevice()!
            metalView.device = defaultDevice
            let renderer = Renderer(metalView: metalView)
            metalView.delegate = renderer
            
            canvas.mousedrug = { point in
                var vector: SIMD2<Float> = [Float(point.x), Float(point.y)]
                vector.x /= 400
                vector.x *= 3
                vector.y /= 300
                vector.y *= 3
                renderer.rotate(xy: vector)
                metalView.setNeedsDisplay(canvas.bounds)
            }
            
            canvas.mousedown = { point in
            }
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

