struct Fridge<Particle> {
    var selected: Particle
    var particles: [Particle]    
    mutating func select(at index: Array<Particle>.Index) {
        swap(&particles[index], &selected)
    }
}

protocol Position {
    var position: SIMD2<Float> { get }
}

extension Fridge where Particle: Position {
    
}

struct TestFridge {
    func run() {
        let one = 0
        let two = [1, 2, 3]
        var fridge = Fridge(selected: one, particles: two)
        print(fridge)
        fridge.select(at: 0)
        print(fridge)
        fridge.select(at: 2)
        print(fridge)
    }
}
