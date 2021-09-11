import Induction
import Algorithms


struct PlainTo3DGrid {
    func grid<Cell>(from plain: [Cell], size: (w: Int, h: Int, d: Int)) -> [[[Cell]]] {
        plain.chunks(ofCount: size.w * size.h).map { chunk -> [[Cell]] in 
            chunk.chunks(ofCount: size.h).map { Array($0) } }
    }
}

struct ColumnsToRows<Element> {
    
    let columns: [[Element]]
    var width: Int { columns.count }
    var height: Int { columns.first!.count }
    var rows: [[Element]] {
        let first = columns.first!.first!
        var rows = Array(repeating: Array(repeating: first, count: width), count: height)
        for x in 0..<width {
            for y in 0..<height {
                rows[y][x] = columns[x][y]
            }
        }
        return rows
    }
    
    init?(columns: [[Element]]) {
        guard columns.isEmpty == false else { return nil }
        guard columns.first!.isEmpty == false else { return nil }
        self.columns = columns
    }
    
    func reshape() {
        
        let column = Array(repeating: "z", count: 10)
        let columns = Array(repeating: column, count: 5)
        print(columns)
        let width = columns.count
        let height = column.count
        var rows = [[String]]()
        for x in 0..<width {
            var row = [String]()
            for y in 0..<height {
                row.append(columns[x][y])
            }
            rows.append(row)
        }
        rows.forEach { print($0) }
    }
    
}

struct TestReshape {
    func run() {
        let column = Array(repeating: "z", count: 5)
        let columns = Array(repeating: column, count: 10)
        columns.forEach { print($0) }
        ColumnsToRows(columns: columns)!.rows.forEach { print($0) }        
    }
}
