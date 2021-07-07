enum Pixel: Equatable, Comparable {
    case empty
    case full(BufferColor)
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
