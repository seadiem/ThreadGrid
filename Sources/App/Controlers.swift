import AppKit

class WindowController: NSWindowController, NSWindowDelegate {
    

    var stored = [Any]()
    let systemCall: (Int) -> Void
    
    init(packet: ControllerPacket) {
        
        var rect = NSRect(x: 100, y: 100, width: 400, height: 300)
        let mask: NSWindow.StyleMask = [.resizable, .titled, .closable, .miniaturizable]
        
        let outwindow = NSWindow(contentRect: rect, styleMask: mask, backing: NSWindow.BackingStoreType.buffered, defer: false)
        outwindow.backgroundColor = NSColor.brown
        outwindow.makeKeyAndOrderFront(outwindow)
        outwindow.isOpaque = false
        outwindow.titleVisibility = .visible
        
        
        let tuple = packet.initialClosure()
        systemCall = packet.systemCallClosure
        super.init(window: outwindow)

        tuple.stored.forEach { stored.append($0) }
        tuple.viewsWindowOne.forEach { outwindow.contentView?.addSubview($0) }
        
        if tuple.viewsWindowThree.isEmpty == false {
            rect.origin.x += rect.width
            var thirdrect = tuple.viewsWindowThree.first!.frame
            thirdrect.origin = rect.origin
            
            if tuple.viewsWindowThree.count == 2 {
                thirdrect.size.height += tuple.viewsWindowThree[1].frame.height
            }
            
            let windowthree = NSWindow(contentRect: thirdrect, styleMask: mask, backing: NSWindow.BackingStoreType.buffered, defer: false)
            windowthree.backgroundColor = NSColor.brown
            windowthree.makeKeyAndOrderFront(outwindow)
            windowthree.isOpaque = false
            windowthree.titleVisibility = .visible
            tuple.viewsWindowThree.forEach { windowthree.contentView?.addSubview($0) }
        }
        
    }
    
    func findMatch() {
        systemCall(10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func windowWillClose(_ notification: Notification) {
        NSApplication.shared.terminate(0)
    }
}
