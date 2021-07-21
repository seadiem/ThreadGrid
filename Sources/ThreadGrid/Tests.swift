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
        var pass = FluidQuickPass()
        pass.pass()
        pass.render()
    }
}
