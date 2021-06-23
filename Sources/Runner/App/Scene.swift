import App
import ThreadGrid

struct Apps {
//    var distortePhoto: ControllerPacket { 
//        DistortPhoto.Setup().prepareDraw() 
//    }
//    var gridTools: ControllerPacket { 
//        GridTools.Setup().prepareDraw() 
//    }
}

struct Scene {
    func run() {
        ThreadGrid().run()
    }
    func runApp() {
//        App(packet: Apps().gridTools).run()
//        App(packet: Apps().distortePhoto).run()   
    }
    
}
