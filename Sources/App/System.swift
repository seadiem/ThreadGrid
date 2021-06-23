#if !os(iOS)
import AppKit


class AppDelegate: NSObject, NSApplicationDelegate {
    
    let windowcontroller: WindowController
    init(packet: ControllerPacket) {
        windowcontroller = WindowController(packet: packet)
        super.init()
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        windowcontroller.window?.delegate = windowcontroller
        windowcontroller.showWindow(self)
    }
}
#endif
