#if !os(iOS)
import AppKit
import Draw

open class Canvas: NSView {
    
    public var mousedrug: ((CGPoint) -> Void)?
    public var mouseup: ((CGPoint) -> Void)?
    public var mousedown: ((CGPoint) -> Void)?
    public var keytap: ((Int) -> Void)?
    public var backcolor: CGColor = CGColor.white
    
    var drawables: [Drawable] = []
    
    public func setDrawables(_ d: [Drawable]) {
        drawables = d
        setNeedsDisplay(bounds)
    }
    
    override public func mouseDragged(with event: NSEvent) {
        let location = event.locationInWindow
        let localpoint = convert(location, from: nil)
        mousedrug?(localpoint)
    }
    
    override public func mouseUp(with event: NSEvent) {
        let location = event.locationInWindow
        let localpoint = convert(location, from: nil)
        mouseup?(localpoint)
    }
    
    override public func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        let localpoint = convert(location, from: nil)
        mousedown?(localpoint)
    }
    
//    override public var acceptsFirstResponder: Bool { get { return true } }
//    
//    override public func keyDown(with event: NSEvent) {
//        keytap?(Int(event.keyCode))
//        super.keyDown(with: event)
//    }
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        draw(canvas: dirtyRect)
    }
    
    func draw(canvas: CGRect) {
        
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        
        ctx.saveGState()
        ctx.setFillColor(backcolor)
        ctx.fill(canvas)
        ctx.restoreGState()
        
        for item in drawables {
            ctx.saveGState()
            item.draw(into: ctx)
            ctx.restoreGState()
        }
    }
}
#endif
