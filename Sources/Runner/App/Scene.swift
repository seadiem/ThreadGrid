import App
import ThreadGrid
import Snake

struct Apps {
    var snakeFluids: ControllerPacket { ThreadGrid.SnakeCook().prepareDraw() }
    var snake: ControllerPacket { Snake.SnakeCook().prepareDraw() }
}

struct Scene {
    func run() {
        App(packet: Apps().snakeFluids).run()
//        App(packet: Apps().snake).run()
    }
    func test() {
        TestThreadGrid().run()
//        SnakeTest().run()
    }
}
