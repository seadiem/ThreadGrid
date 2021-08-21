struct Track {        
    var previewTouch: SIMD2<Float>?
    var currentTouch: SIMD2<Float>?
    mutating func getDiff(touch: SIMD2<Float>) -> SIMD2<Float>? {
        previewTouch = currentTouch
        currentTouch = touch
        guard let cur = currentTouch, let prev = previewTouch else { return nil }
        let diff = cur - prev
        return diff
    }
    mutating func touchUp() {
        previewTouch = nil
        currentTouch = nil
    }
}
