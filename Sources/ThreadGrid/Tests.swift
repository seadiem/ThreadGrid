import CoreStructures
import Induction
import RenderSetup

public struct TestThreadGrid {
    public init() {}
    public func run() {
//        TestPixel().run()
//        TestFridge().run()
//        CheckSimd().run()
//        Geometry().test()
//        Ctest().run()
//        Test3DGrid().run()
//        TestQuickPass().run()
//        TestStencil().run()
    }
}

struct TestQuickPass {
    func run() {
        debug()
    }
    func reshape() {
        TestReshape().run()
    }
    func debug() {
        var pass = QuickPass3D()
        pass.pass()
        pass.render()
    }
    func fluid() {
        var pass = QuickPass3D()
        while let _ = readLine() {
            pass.pass()
            pass.render()
        }
    }
}

struct Ctest {
    func testArray() {
        let s: Array<Int32> = [1, 2, 3, 4]
        let uint8Pointer = UnsafeMutablePointer<Int32>.allocate(capacity: 4)
        uint8Pointer.initialize(from: s, count: 4)
        printIntArrayContent(uint8Pointer, 4)
    }
    func testStencil() {
        makeStencil()
    }
    func run() {
        testStencil()
    }
}

struct CheckSimd {
    func run() {
        let a: SIMD2<Int> = [0, 0] 
        let b = a &+ 1
        print(b)
    }
}

struct Test3DGrid {
    
    struct TestCell: EmptyInit, LengthSupplier, CustomStringConvertible {
        static var length: Int { MemoryLayout<TestCell>.stride }
        let index: SIMD3<Int>
        var description: String { "(\(index.x) \(index.y) \(index.z))" }
        var isEmpty: Bool { index == .zero }
        init() {
            index = .zero
        }
    }
    
    func run() {
        let packet = RenderPacket()
        let grid = ThreadGridBuffer3D<TestCell>(device: packet.device, width: 4, height: 4, depth: 4)
        grid.grids.forEach { field in
            field.forEach { column in
                print(column)
            }
        }
        grid.fillBuffer()
 //       grid.unbind()
    }
    
}

struct ArrayBug {
    func check() {
        let a = [1, 3]
        get(array: a)
        let b = [a, a]
        get2(array: b)
//        get(array: b)
        getAndBreak(array: b)
    }
    func get(array: [Int]) {
        array.forEach { print($0) }
    }
    func get2(array: [[Int]]) {
        array.forEach { print($0) }
    }
    func getAndBreak<Element>(array: [Element]) {
    }
    
}
