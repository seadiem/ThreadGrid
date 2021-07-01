import App
import ThreadGrid

struct Apps {
    var threadGrid: ControllerPacket { Setup().prepareDraw() }
}

struct Scene {
    func run() {
        App(packet: Apps().threadGrid).run()
    }
}
