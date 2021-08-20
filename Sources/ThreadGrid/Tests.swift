import CoreStructures

public struct TestThreadGrid {
    public init() {}
    public func run() {
//        TestPixel().run()
//        TestFridge().run()
//        TestQuickPass().run()
//        CheckSimd().run()
//        Geometry().test()
        Ctest().run()
    }
}

struct TestQuickPass {
    func run() {
        fluid()
    }
    func reshape() {
        TestReshape().run()
    }
    func debug() {
        var pass = DebugQuickPass()
        pass.pass()
        pass.render()
    }
    func fluid() {
        var pass = FluidQuickPass()
        while let _ = readLine() {
            pass.pass()
            pass.render()
            pass.further()    
        }
    }
}

struct Ctest {
    func run() {
        let s: Array<Int32> = [1, 2, 3, 4]
        let uint8Pointer = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        uint8Pointer.initialize(from: s, count: 4)
        printIntArrayContent(uint8Pointer, 4)
    }
}

struct CheckSimd {
    func run() {
        let a: SIMD2<Int> = [0, 0] 
        let b = a &+ 1
        print(b)
    }
}
