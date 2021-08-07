import CoreGraphics


public protocol Renderer2D {
    
    func draw(color: Color, in rect: CGRect)
    func move(to point: CGPoint)
    func line(to point: CGPoint)
    func setColor(color: Color)
    func fill()
    func stroke()
    func setWidth(w: Double)
    func drawPath(points: [CGPoint])
    func draw(image: CGImage, in rect: CGRect)
    func draw(text: String, at point: CGPoint, fontsize: Int, color: Color)
    func setBlend(mode: CGBlendMode)
    func circleAt(point: CGPoint, radius: Double)
    func push()
    func pop()
    func close()
    func rotate(angel: Float)
    func setLineCap(cap: CGLineCap)
}

public protocol Drawable {
    func draw(into renderer: Renderer2D)
}
