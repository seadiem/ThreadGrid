import CoreGraphics

public extension SIMD2 where Scalar: BinaryFloatingPoint {
    var cgpoint: CGPoint { CGPoint(x: Double(x), y: Double(y)) }
    var simd3: SIMD4<Scalar> { [x, y, 0] }
    var cgsize: CGSize { CGSize(diagonal: self) }
    init(point: CGPoint) { self.init([Scalar(point.x), Scalar(point.y)]) }
}

public extension SIMD2 where Scalar: BinaryInteger {
    var cgpoint: CGPoint { CGPoint(x: Double(x), y: Double(y)) }
    var cgsize: CGSize { CGSize(diagonal: self) }
    init(point: CGPoint) { self.init([Scalar(point.x), Scalar(point.y)]) }
}

public extension SIMD3 where Scalar: BinaryFloatingPoint {
    var cgpoint: CGPoint { CGPoint(x: Double(x), y: Double(y)) }
    var simd4: SIMD4<Scalar> { [x, y, z, 1] }
}

public extension SIMD4 where Scalar: BinaryFloatingPoint {
    var cgpoint: CGPoint { CGPoint(x: Double(x), y: Double(y)) }
}

public extension SIMD4 where Scalar: BinaryInteger {
    var cgpoint: CGPoint { CGPoint(x: Double(x), y: Double(y)) }
}

public extension CGPoint {
    var xdouble: Double { Double(x) }
    var ydouble: Double { Double(y) }
    var xfloat : Float  { Float(x)  }
    var yfloat : Float  { Float(y)  }
    var simd2float : SIMD2<Float>  { [Float(x), Float(y)]      }
    var simd2double: SIMD2<Double> { [Double(x), Double(y)]    }
    var simd3float : SIMD3<Float>  { [Float(x), Float(y), 0]   }
    var simd3double: SIMD3<Double> { [Double(x), Double(y), 0] }
}

public extension CGSize {
    init<Scalar>(diagonal: SIMD2<Scalar>) where Scalar: BinaryFloatingPoint {
        self.init(width: Double(diagonal.x), height: Double(diagonal.y))
    }
    init<Scalar>(diagonal: SIMD2<Scalar>) where Scalar: BinaryInteger {
        self.init(width: Int(diagonal.x), height: Int(diagonal.y))
    }
    var diagonalFloat: SIMD2<Float> { [Float(width), Float(height)] }
    var simdFloatCenter: SIMD2<Float> { diagonalFloat / 2 }
}
