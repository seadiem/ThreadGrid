import App
import ThreadGrid

struct Apps {
    var threadGrid: ControllerPacket { FluidCook().prepareDraw() }
    var snake: ControllerPacket { SnakeCook().prepareDraw() }
}

struct Scene {
    func run() {
//        App(packet: Apps().threadGrid).run()
        App(packet: Apps().snake).run()
    }
    func test() {
        TestThreadGrid().run()
    }
}
