import MetalKit
import Draw
import App

@available(OSX 10.11, *)
public struct Setup {
    
    public init() {}
    
    public func prepareDraw() -> ControllerPacket {
        
        
        
        /// Вызывается в методе вью контроллера
        func initialdraw() -> (viewsWindowOne: [NSView], viewsWindowTwo: [NSView], viewsWindowThree: [NSView], stored: [Any]) {
            
            let canvas = Canvas(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
            canvas.backcolor = Color.brown.cgcolor
            
            
            let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
            metalView.preferredFramesPerSecond = 10
            metalView.enableSetNeedsDisplay = true
            metalView.isPaused = true
            canvas.addSubview(metalView)
            let defaultDevice = MTLCreateSystemDefaultDevice()!
            metalView.device = defaultDevice
            let renderer = Renderer(metalView: metalView)
            metalView.delegate = renderer

            
            canvas.mousedrug = { point in
                renderer.point = [Float(point.x), -Float(point.y) + 200]
                metalView.setNeedsDisplay(canvas.bounds)
                
//                DispatchQueue.global().async {
//                    renderer.random()
//                    DispatchQueue.main.sync {
//                        metalView.setNeedsDisplay(canvas.bounds)                        
//                    }                    
//                }
            }
                        
            defer {
                DispatchQueue.global().async {
                    var command = ""
                    while command != "end" {
                        print("input command:")
                        guard let line = readLine() else { continue }
                        switch line {
                        case "sort":
                            DispatchQueue.main.async {
                                renderer.sort()
                                metalView.setNeedsDisplay(canvas.bounds)
                            }
                        default: break
                        }
                        command = line
                        print("command: \(command)")
                    }
                    print("end commands")
                }
            }
            
            return ([canvas], [], [], [1])
        }
        
        
        /// Вызывается в методе вью контроллера
        func system(a: Int) {}
        
        
        let packet = ControllerPacket(initialClosure: initialdraw, systemCallClosure: system)
        return packet
    }
}
