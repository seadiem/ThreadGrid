import Induction

enum Pixel: Equatable, Comparable, EmptyInit {
    
    case empty
    case full(BufferColor)
    
    var isEmpty: Bool { self == .empty }
    
    init() {
        self = .empty
    }
    
    static func == (lhs: Pixel, rhs: Pixel) -> Bool {
        switch lhs {
        case .full(let leftcolor):
            switch rhs {
            case .full(let rightcolor): return leftcolor == rightcolor
            case .empty: return false
            }
        case .empty:
            switch rhs {
            case .full: return false
            case .empty: return true
            }
        }
    }
    static func < (lhs: Pixel, rhs: Pixel) -> Bool {
        switch lhs {
        case .full(let leftcolor):
            switch rhs {
            case .full(let rightcolor): return leftcolor < rightcolor
            case .empty: return false
            }
        case .empty:
            switch rhs {
            case .full: return true
            case .empty: return true
            }
        }
    }
}

struct TestPixel {
    func run() {
        var lhs = Pixel()
        var rhs = Pixel.full(BufferColor.green())
        assert(rhs > lhs)
        lhs = Pixel.full(BufferColor(red: 100, green: 100, blue: 100))
        rhs = Pixel.full(BufferColor(red: 10, green: 10, blue: 10))
        assert(lhs > rhs)
        rhs = Pixel()
        assert(lhs > rhs)
        print("pixel tests compleet")
    }
}

struct BufferColor: Equatable, Comparable {
    static func green() -> BufferColor { BufferColor(red: 30, green: 110, blue: 40) }
    static func random() -> BufferColor {
        BufferColor(red: Int.random(in: 10...50), 
                    green: Int.random(in: 100...150), 
                    blue: Int.random(in: 10...50))
    }
    static func randomLight() -> BufferColor {
        BufferColor(red: Int.random(in: 10...20), 
                    green: Int.random(in: 100...110), 
                    blue: Int.random(in: 10...20))
    }
    static func white() -> BufferColor { BufferColor(red: 255, green: 255, blue: 255) }
    let red: Int
    let green: Int
    let blue: Int
    var color: SIMD4<Float> { [Float(red) / 255, Float(green) / 255, Float(blue) / 255, 1] }
    static func < (lhs: BufferColor, rhs: BufferColor) -> Bool {
        lhs.red < rhs.red
    }
}
