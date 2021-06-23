#if !os(iOS)
import AppKit

public struct ControllerPacket {
    
    public typealias InitialClosure = () -> (viewsWindowOne: [NSView], viewsWindowTwo: [NSView], viewsWindowThree: [NSView], stored: [Any])
    public typealias SystemClosure = (Int) -> Void

    let initialClosure: InitialClosure
    let systemCallClosure: SystemClosure
    
    public init(initialClosure: @escaping InitialClosure, systemCallClosure: @escaping SystemClosure) {
        self.initialClosure = initialClosure
        self.systemCallClosure = systemCallClosure
    }
}
#endif
