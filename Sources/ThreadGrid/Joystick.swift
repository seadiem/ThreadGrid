import Draw
import CoreGraphics

public struct Joystick: Drawable {

    let center: SIMD2<Double>
    var stick: SIMD2<Double>
    
    public init(center: SIMD2<Double>) {
        self.center = center
        stick = .zero
    }
    
    
    mutating func touch(at position: SIMD2<Double>) {
        stick = position - center
    }
    
    public func draw(into renderer: Renderer2D) {
        let point = center + stick
        renderer.setWidth(w: 2)
        renderer.setColor(color: Color.body)
        renderer.move(to: CGPoint(x: point.x, y: point.y))
        renderer.drawPath(points: [CGPoint(x: point.x, y: point.y), CGPoint(x: center.x, y: center.y)])
        renderer.stroke()
        renderer.fill()
        renderer.move(to: CGPoint(x: point.x, y: point.y))
        renderer.circleAt(point: CGPoint(x: point.x, y: point.y), radius: 5)
        renderer.move(to: CGPoint(x: center.x, y: center.y))
        renderer.circleAt(point: CGPoint(x: center.x, y: center.y), radius: 5)
        renderer.stroke()
    }
}

