#if !os(iOS)
import AppKit
import Draw



struct Template {
    
    /// main.swit
    /// Template.Runner().run()
    struct Runner {
         func run() {
             let packet = Template().prepareDraw()
             App(packet: packet).run()
         }
     }
    
    struct VertexFridge: Drawable {    
//        let triangel: Triangel
        init() {
//            triangel = Triangel()
        }
        func draw(into renderer: Renderer2D) {
 //           triangel.draw(into: renderer)
        }
    } 
    
    func prepareDraw() -> ControllerPacket {
        
        let backedModel = VertexFridge()
     
        defer {
            DispatchQueue.global().async {
                var command = ""
                while command != "end" {
                    print("input command:")
                    guard let line = readLine() else { continue }
                    command = line
                    print("command: \(command)")
                }
                print("end commands")
            }
        }
        
        func initialdraw() -> (viewsWindowOne: [NSView], viewsWindowTwo: [NSView], viewsWindowThree: [NSView], stored: [Any]) {
                    
            let canvas = Canvas(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
            canvas.backcolor = Color.brown.cgcolor
            
            let canvastwo = Canvas(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 400, height: 300)))
            canvastwo.backcolor = Color.darkbrown.cgcolor
            
            canvas.setDrawables([backedModel])
            let ndcModel = backedModel            
            canvastwo.setDrawables([ndcModel])
            
            canvas.mousedrug = { point in }
            canvastwo.mousedrug = { point in }
            return ([canvas], [canvastwo], [], [1])
        }
        
        func system(a: Int) {}
        
        
        let packet = ControllerPacket(initialClosure: initialdraw, systemCallClosure: system)
        return packet
    }
}
#endif
