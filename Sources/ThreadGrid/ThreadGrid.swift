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
    public func run() {
        print("run")
        render()
        _ = readLine()
    }
}


