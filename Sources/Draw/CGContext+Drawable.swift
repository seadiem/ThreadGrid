

#if canImport(Appkit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension CGContext {
    
    func testDraw() {
        #if os(macOS)
        setFillColor(CGColor(red: 183/255, green: 1, blue: 1, alpha: 1.0))
        fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        #elseif os(iOS)
        #endif
    }
    
    func push() {
        saveGState()
    }
    
    func pop() {
        restoreGState()
    }
    
    func close() {
        closePath()
    }
    
    func stroke() {
        strokePath()
    }
    
    func setLineCap(cap: CGLineCap) {
        setLineCap(cap)
    }
    
    func rotate(angel: Float) {
        rotate(by: CGFloat(angel))
    }
    
    func fill() {
        fillPath(using: CGPathFillRule.winding)
    }
    
    func line(to point: CGPoint) {
        addLine(to: point)
    }
    
    func draw(color: Color, in rect: CGRect) {
        setFillColor(color.cgcolor)
        fill(rect)
    }
    
    func setWidth(w: Double) {
        setLineWidth(CGFloat(w))
    }
    func setColor(color: Color) {
        setStrokeColor(color.cgcolor)
        setFillColor(color.cgcolor)
    }
    func drawPath(points: [CGPoint]) {
        strokeLineSegments(between: points)
    }
    
    func arc(center: CGPoint, from fromangel: Double, to toangel: Double, radius: Double) {
        addArc(center: center, radius: CGFloat(radius), startAngle: CGFloat(fromangel), endAngle: CGFloat(toangel), clockwise: false)
    }
    
    func circleAt(point: CGPoint, radius: Double) {
        arc(center: point, from: 0, to: Double.pi * 2, radius: radius)
    }
    
    func draw(image: CGImage, in rect: CGRect) {
        draw(image, in: rect)
    }
    
    func draw(text: String, at point: CGPoint, fontsize: Int, color: Color = .white) {
        
        #if os(macOS)
//        let h2 = NSFont.init(name: "Georgia-Bold", size: 8) ?? NSFont.systemFont(ofSize: 8)
        let h1 = NSFont.init(name: "Georgia-Bold", size: CGFloat(fontsize)) ?? NSFont.systemFont(ofSize: CGFloat(fontsize))
        #elseif os(iOS)
        var h2 = UIFont.init(name: "Georgia-Bold", size: 8) ?? UIFont.systemFont(ofSize: 8)
        var h1 = UIFont.init(name: "Georgia-Bold", size: CGFloat(fontsize)) ?? UIFont.systemFont(ofSize: CGFloat(fontsize))
        #endif
        
        let lineText = NSMutableAttributedString(string: text)
        
        let color = color.cgcolor
        
//        #if os(macOS)
//        let color = color.cgcolor
//        #elseif os(iOS)
//        let color = UIColor.white.cgColor
//        #endif
        
        lineText.addAttributes([NSAttributedString.Key.font : h1,
                                NSAttributedString.Key.foregroundColor: color],
                               range: NSMakeRange(0,lineText.length))
        let lineToDraw: CTLine = CTLineCreateWithAttributedString(lineText)
        setTextDrawingMode(.fill)
        textPosition = point
        CTLineDraw(lineToDraw, self)
    }
    
    func setBlend(mode: CGBlendMode) {
        
    }
    
}

extension CGContext: Renderer2D {
//    
//    public func draw(text: String, at point: CGPoint, fontsize: Int) {
//    }
    
}
