import Induction

struct Hanoy {
    
    func run() {
        var h = HorisontalStck<Block<[Pixel]>>()
        let v = VerticalStack<Block<[Pixel]>>()
        
        h.push(column: v)
        h.push(column: v)
        h.push(column: v)
        
        var pixelrow = Array(repeating: Pixel.empty, count: 30)
        var statement = Block(box: pixelrow)
        h.push(block: statement, to: .leftStack)
        h.push(block: statement, to: .middleStack)
        h.push(block: statement, to: .rightStack)
        
        pixelrow = Array(repeating: Pixel.full(.green()), count: 30)
        statement = Block(box: pixelrow)
        for _ in 0...30 {
            h.push(block: statement, to: .middleStack)
        }
    }
    
}
