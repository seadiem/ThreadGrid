import simd
struct Geometry {
    func test () {
        field()
    }
    func dot() {
        let w: SIMD2<Float> = [9, 6]
        let v: SIMD2<Float> = [3, 2]
        let p = simd_dot(w, v)
        print("p: \(p)")
        let wp = p / simd_length(v)
        print("wp: \(wp), w: \(simd_length(w))")
    }
    func field() {
        let h: SIMD2<Float> = [3, 3]
        var t: SIMD2<Float> = [7, 5]
        var v = t - h
        var w: SIMD2<Float> = [0, 1]
        var p = simd_dot(w, v)
        var wp = p / simd_length(v)
        print("wp: \(wp), w: \(simd_length(w)), v: \(v)")
        
        t = [7, 3]
        v = t - h
        p = simd_dot(w, v)
        wp = p / simd_length(v)
        print("wp: \(wp), w: \(simd_length(w)), v: \(v)")
        
        t = [3, 7]
        v = t - h
        p = simd_dot(w, v)
        wp = p / simd_length(v)
        print("wp: \(wp), w: \(simd_length(w)), v: \(v)")
        
        w = [2, 1]
        t = [7, 5]
        v = t - h
        p = simd_dot(w, v)
        wp = p / simd_length(v)
        print("wp: \(wp), w: \(simd_length(w)), v: \(v)")
        
    }
}
