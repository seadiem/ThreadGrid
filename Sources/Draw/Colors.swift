
import CoreGraphics

#if os(macOS)
import CoreGraphics
#elseif os(iOS)
import UIKit
#endif

public struct Color: Codable, Equatable {
    
    public static func makeMaterial(color: Color) -> SIMD4<Float> {
        

        
        switch color {
        case .elephant: return [0.45, 0.55, 0.5, 0]
        case .barrelelephant: return [0.7, 0.3, 0.8, 0]
        case .black: return [0.7, 0.3, 0.3, 0]
        case .deepviolett: return [0.5, 0.5, 0.1, 0]
        case .absolutviolett: return [0.6, 0.4, 1.0, 0]
        case .skydeepgreen: return [0.6, 0.4, 0.3, 0]
        default: return [1.0, 0.0, 0.5, 0]
        }
    }
    
    public static func sameJustAlpha(color : Color) -> Color {
        return Color(red: color.red, green: color.green, blue: color.blue, alpha: 0.0)
    }
    
    public static func sameJustDarken(color : Color, k: Float) -> Color {
        let simd = SIMD4<Double>(color.simd4 * k)
        return Color(red: simd.x, green: simd.y, blue: simd.z, alpha: color.alpha)
    }
    
    public static var nitralpinkAlpha: Color {
        get { Color(red: 202.0/255, green: 137.0/246, blue: 234.0/255, alpha: 0.5) }
    }
    
    public static var numberred: Color {
        get { Color(red: 255.0/255, green: 72.0/255, blue: 71.0/255, alpha: 1.0) }
    }
    
    public static var numberreddeep: Color {
        get { Color(red: 242.0/255, green: 20.0/255, blue: 71.0/255, alpha: 1.0) }
    }
    
    public static var numberreddeeporange: Color {
        get { Color(red: 242.0/255, green: 59.0/255, blue: 71.0/255, alpha: 1.0) }
    }
    
    public static var elephant: Color {
        get { Color(red: 255.0/255, green: 239.0/255, blue: 215.0/255, alpha: 1.0) }
    }
    
    public static var barrelelephant: Color {
        get { Color(red: 254.0/255, green: 239.0/255, blue: 215.0/255, alpha: 1.0) }
    }
    
    public static var bottomLightAlpha: Color {
        get { Color(red: 91.0/255, green: 255.0/255, blue: 212.0/255, alpha: 1.0) }
    }
    
    public static var greenneonAlpha: Color {
        get { Color(red: 91.0/255, green: 255.0/255, blue: 212.0/255, alpha: 1.0) }
    }
    
    public static var alpha: Color {
        get { Color(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.0) }
    }
    
    public static var fieldBrown: Color {
        get { Color(red: 84/255, green: 57/255, blue: 30/255, alpha: 0.4) }
    }
    
    public static var fieldMarkup: Color {
        get { Color(red: 233/255, green: 221/255, blue: 197/255, alpha: 0.9) }
    }
    
    public static var brown: Color {
        get { Color(red: 149/255, green: 98/255, blue: 57/255, alpha: 1.0) }
    }
    
    public static var darkbrown: Color {
        get { Color(red: (149-10)/255, green: (98-10)/255, blue: (57-10)/255, alpha: 1.0) }
    }
    
    public static var backbrown: Color {
        get { Color(red: 112.0/255, green: 75.0/255, blue: 39.0/255, alpha: 1.0) }
    }
    
    public static var backbrownrender: Color {
        get { Color(red: 92.0/255, green: 59.0/255, blue: 29.0/255, alpha: 1.0) }
    }
    
    public static var horisontbrownsRGB: Color {
        get { Color(red: 132.0/255, green: 89.0/255, blue: 45.0/255, alpha: 1.0) }
    }
 
    public static var horisontpinkRGB: Color {
        get { Color(red: 255.0/255, green: 118.0/255, blue: 94.0/255, alpha: 1.0) }
    }
    
    public static var deepskysRGB: Color {
        get { Color(red: 128.0/255, green: 53.0/255, blue: 44.0/255, alpha: 1.0) }
    }
    
    public static var red: Color {
        get { Color(red: 255.0/255, green: 126.0/255, blue: 121.0/255, alpha: 1.0) }
    }
    
    public static var pink: Color {
         get { Color(red: 229.0/255, green: 51.0/255, blue: 75.0/255, alpha: 1.0) }
    }
    
    public static var violett: Color {
         get { Color(red: 243.0/255, green: 105.0/255, blue: 212.0/255, alpha: 1.0) }
    }
    
    public static var yellow: Color {
         get { Color(red: 243.0/255, green: 240.0/255, blue: 212.0/255, alpha: 1.0) }
    }
    
    public static var deepviolett: Color {
           get { Color(red: 91.0/255, green: 88.0/255, blue: 212.0/255, alpha: 1.0) }
    }
    
    public static var absolutviolett: Color {
        get { Color(red: 119.0/255, green: 64.0/255, blue: 201.0/255, alpha: 1.0) }
    }
    
    public static var skydeep: Color {
        get { Color(red: 119.0/255, green: 197.0/255, blue: 255.0/255, alpha: 1.0) }
    }
    
    public static var skydeepgreen: Color {
        get { Color(red: 161.0/255, green: 156.0/255, blue: 255.0/255, alpha: 1.0) }
    }
    
    public static var deepviolettrender: Color {
        get { Color(red: 111.0/255, green: 113.0/255, blue: 220.0/255, alpha: 1.0) }
    }
    
    public static var deepviolettrenderdarked: Color {
        get { Color(red: 111.0 - 5/255, green: 113.0 - 5/255, blue: 220.0 - 5/255, alpha: 1.0) }
    }
    
    public static var lightviolett: Color {
        get { Color(red: 165.0/255, green: 172.0/246, blue: 212.0/255, alpha: 1.0) }
    }
    public static var extralightviolett: Color {
        get { Color(red: 211.0/255, green: 211.0/246, blue: 255.0/255, alpha: 1.0) }
    }
    
    public static var nitralpink: Color {
        get { Color(red: 202.0/255, green: 137.0/246, blue: 234.0/255, alpha: 1.0) }
    }
    
    public static var greenneon: Color {
           get { Color(red: 91.0/255, green: 255.0/255, blue: 212.0/255, alpha: 0.5) }
    }
    
    public static var greenneonfull: Color {
        get { Color(red: 91.0/255, green: 255.0/255, blue: 212.0/255, alpha: 1.0) }
    }
    
    public static var warmgreen: Color {
           get { Color(red: 191.0/255, green: 255.0/255, blue: 145.0/255, alpha: 1.0) }
    }
    
    public static var lightgray: Color {
           get { Color(red: 90.0/255, green: 90.0/255, blue: 90.0/255, alpha: 1.0) }
    }
    
    public static var orange: Color {
        get { Color(red: 255.0/255, green: 139.0/255, blue: 0.0/255, alpha: 1.0) }
    }
    
    
    public static var one: Color {
        get { Color(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0) }
    }
    
    public static var two: Color {
        get { Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0) }
    }
    
    public static var three: Color {
        get { Color(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0) }
    }
    
    public static var four: Color {
        get { Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) }
    }
    
    public static var five: Color {
        get { Color(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0) }
    }
    
    public static var fivealpha: Color {
        get { Color(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0) }
    }
    
    public static var six: Color {
        get { Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) }
    }
    
    public static var seven: Color {
        get { Color(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0) }
    }
    
    public static var black: Color {
        get { Color(red: 84.0 / 255, green: 71.0 / 255, blue: 72.0 / 255, alpha: 1.0) }
    }
    
    public static var deepblack: Color {
        get { Color(red: 20.0 / 255, green: 20.0 / 255, blue: 20.0 / 255, alpha: 1.0) }
    }
    
    public static var white: Color {
        get { Color(red: 255.0 / 255, green: 255.0 / 255, blue: 255 / 255.0, alpha: 1.0) }
    }
    
    public static var body: Color {
        get { Color(red: 216.0 / 255, green: 169.0 / 255, blue: 80 / 255.0, alpha: 1.0) }
    }
    
    public static var bodyrender: Color {
        get { Color(red: 206.0 / 255, green: 153.0 / 255, blue: 63 / 255.0, alpha: 1.0) }
    }
    
    public static var bodycian: Color {
        get { Color(red: 62.0 / 255, green: 166.0 / 255, blue: 184 / 255.0, alpha: 1.0) }
    }
    
    public static var bodypink: Color {
        get { Color(red: 201.0 / 255, green: 38.0 / 255, blue: 80 / 255.0, alpha: 1.0) }
    }
    
    public static var scoresback: Color {
        get { Color(red: 128.0 / 255, green: 7.0 / 255, blue: 1 / 255.0, alpha: 0.8) }
    }
    
    public static var deepyellow: Color {
        get { Color(red: 255.0 / 255, green: 219.0 / 255, blue: 1 / 22.0, alpha: 0.8) }
    }
    
    public static var random: Color {
        getBy(integer: Int.random(in: 0...7) )
    }
    
    public static func getBy(integer: Int) -> Color {
        
        var integer = integer
        
        if integer > 14 {
            integer = integer % 14
        }
        
        switch integer {
            case 0: return one
            case 1: return two
            case 2: return three
            case 3: return four
            case 4: return five
            case 5: return six
            case 6: return seven
            case 7: return greenneon
            case 8: return red
            case 9: return pink
            case 10: return deepviolett
            case 11: return yellow
            case 12: return violett
            case 13: return lightgray
            case 14: return warmgreen
            default: return deepviolett
        }
    }
    
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    public var cgcolor: CGColor {
        #if os(macOS)
        return CGColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        #elseif os(iOS)
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha)).cgColor
        #endif
    }
    
    public var simd3: SIMD3<Float> {
        return SIMD3([Float(red), Float(green), Float(blue)])
    }
    
    public var simd4: SIMD4<Float> {
        return SIMD4([Float(red), Float(green), Float(blue), Float(alpha)])
    }
}
