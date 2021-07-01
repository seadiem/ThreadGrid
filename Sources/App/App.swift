import AppKit


public class App {
    
    private let app: NSApplication
    private let delegate: AppDelegate
    
    public init(packet: ControllerPacket) {
        app = NSApplication.shared
        delegate = AppDelegate(packet: packet)
        app.delegate = delegate
        app.setActivationPolicy(.regular)
    }
    
    public func run() {
        app.run()
    }
    
}
