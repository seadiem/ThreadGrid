import Dispatch

public struct ThreadGrid {
    public init() {}
    func render() {
        
        let origin: [Float] = [1, 2, 3, 4, 5]
        
        let packet = RenderPacket()
        let pass = RenderPassOne(packet: packet, origin: origin) { array in
            print("result: \(array)")
        }
        DispatchQueue.global().async {
            pass.pass()            
        }
    }
    
    func passStack() {
        _ = PassStack(packet: RenderPacket())
    }
    
    public func run() {
        print("run")
        passStack()
        _ = readLine()
    }
}


