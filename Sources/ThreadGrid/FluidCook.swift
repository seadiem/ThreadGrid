#if os(macOS)
import MetalKit
import Draw
import App

@available(OSX 10.11, *)
public struct FluidCook {
    
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
            let renderer = AdvectRendererOne(metalView: metalView)
            metalView.delegate = renderer
            
            var joystick = Joystick(center: [350, 250])
            canvas.setDrawables([joystick])
            
            canvas.mousedrug = { point in
                renderer.set(point: [Float(point.x), -Float(point.y) + 200])
 //               metalView.setNeedsDisplay(canvas.bounds)
                joystick.touch(at: [Double(point.x), Double(point.y)])
                canvas.setDrawables([joystick])
            }
            
            canvas.mousedown = { point in
 //               renderer.set(point: [Float(point.x), -Float(point.y) + 200])
                metalView.setNeedsDisplay(canvas.bounds)
            }
            
            canvas.keytap = { key in 
                print("key: \(key)")
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
    
    func command(renderer: AdvectRendererOne, metalView: MTKView, canvas: NSView) {
        DispatchQueue.global().async {
            var command = ""
            while command != "end" {
                print("input command:")
                guard let line = readLine() else { continue }
                switch line {
                case "force": 
                    print("input force 'X:Y'")
                    if let f = readLine() {
                        DispatchQueue.main.async {
                            let s = f.split(separator: ":")
                            guard s.count == 2, let x = Float(s.first!), let y = Float(s.last!) else { return }
                            renderer.pass(forceX: x, forceY: y)
                        }
                    }
                case "sort":
                    DispatchQueue.main.async {
                        //                       renderer.sort()
                        metalView.setNeedsDisplay(canvas.bounds)
                    }
                case "part":
                    DispatchQueue.main.async {
                        //                      renderer.part()
                        metalView.setNeedsDisplay(canvas.bounds)
                    }
                case "shuf":
                    DispatchQueue.main.async {
                        //                     renderer.shuffle()
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
    
}
#endif
