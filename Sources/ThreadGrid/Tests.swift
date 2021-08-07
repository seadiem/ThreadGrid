public struct TestThreadGrid {
    public init() {}
    public func run() {
//        TestPixel().run()
//        TestFridge().run()
//        TestQuickPass().run()
        CheckSimd().run()
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

struct CheckSimd {
    func run() {
        let a: SIMD2<Int> = [0, 0] 
        let b = a &+ 1
        print(b)
    }
}
