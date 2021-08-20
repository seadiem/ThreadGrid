import App
import ThreadGrid
import Snake

struct Apps {
    var threadGrid: ControllerPacket { FluidCook().prepareDraw() }
    var snakeFluids: ControllerPacket { ThreadGrid.SnakeCook().prepareDraw() }
    var snake: ControllerPacket { Snake.SnakeCook().prepareDraw() }
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
