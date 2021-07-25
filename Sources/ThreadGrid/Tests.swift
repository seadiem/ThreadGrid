public struct TestThreadGrid {
    public init() {}
    public func run() {
//        TestPixel().run()
//        TestFridge().run()
        TestQuickPass().run()
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
