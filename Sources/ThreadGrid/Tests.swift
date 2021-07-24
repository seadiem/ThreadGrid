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
        debug()
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
        pass.fridge.noPassRender()
        while let _ = readLine() {
            pass.pass()
            pass.render()
            pass.further()    
        }
    }
}
