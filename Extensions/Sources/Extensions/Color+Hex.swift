import SwiftUI

public extension String {
    var uiColor: UIColor {
        return UIColor(Color(hex: self))
    }
}

public extension UIColor {
    var hex: String {
        let values = self.cgColor.components
        var outputR: Int = 0
        var outputG: Int = 0
        var outputB: Int = 0
        
        switch values!.count {
        case 1:
            outputR = Int(values![0] * 255)
            outputG = Int(values![0] * 255)
            outputB = Int(values![0] * 255)
        case 2:
            outputR = Int(values![0] * 255)
            outputG = Int(values![0] * 255)
            outputB = Int(values![0] * 255)
        case 3:
            outputR = Int(values![0] * 255)
            outputG = Int(values![1] * 255)
            outputB = Int(values![2] * 255)
        case 4:
            outputR = Int(values![0] * 255)
            outputG = Int(values![1] * 255)
            outputB = Int(values![2] * 255)
        default:
            break
        }
        return "#" + String(format:"%02X", outputR) + String(format:"%02X", outputG) + String(format:"%02X", outputB)
    }
}


public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgbValue = UInt32(hex, radix: 16)
        let r = Double((rgbValue! & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue! & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue! & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
    
    var hex: String {
        let values = UIColor(self).cgColor.components
        var outputR: Int = 0
        var outputG: Int = 0
        var outputB: Int = 0
        
        switch values!.count {
        case 1:
            outputR = Int(values![0] * 255)
            outputG = Int(values![0] * 255)
            outputB = Int(values![0] * 255)
        case 2:
            outputR = Int(values![0] * 255)
            outputG = Int(values![0] * 255)
            outputB = Int(values![0] * 255)
        case 3:
            outputR = Int(values![0] * 255)
            outputG = Int(values![1] * 255)
            outputB = Int(values![2] * 255)
        case 4:
            outputR = Int(values![0] * 255)
            outputG = Int(values![1] * 255)
            outputB = Int(values![2] * 255)
        default:
            break
        }
        return "#" + String(format:"%02X", outputR) + String(format:"%02X", outputG) + String(format:"%02X", outputB)
    }
}

