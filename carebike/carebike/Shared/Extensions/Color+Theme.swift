import SwiftUI

extension Color {
    static let theme = ColorTheme()
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColorTheme {
    let primary = Color(hex: "007AFF")
    let secondary = Color(hex: "5856D6")
    let accent = Color(hex: "FF9500")
    
    let success = Color(hex: "34C759")
    let warning = Color(hex: "FF9500")
    let error = Color(hex: "FF3B30")
    let info = Color(hex: "5AC8FA")
    
    let background = Color(hex: "F2F2F7")
    let cardBackground = Color.white
    
    let textPrimary = Color(hex: "000000")
    let textSecondary = Color(hex: "8E8E93")
    let textTertiary = Color(hex: "C7C7CC")
    
    let bikeRoad = Color(hex: "007AFF")
    let bikeMountain = Color(hex: "34C759")
    let bikeElectric = Color(hex: "FF9500")
    let bikeCommuter = Color(hex: "5856D6")
    let bikeGravel = Color(hex: "8E8E93")
    
    func color(for bikeType: BikeType) -> Color {
        switch bikeType {
        case .road: return bikeRoad
        case .mountain: return bikeMountain
        case .electric: return bikeElectric
        case .commuter: return bikeCommuter
        case .gravel: return bikeGravel
        default: return primary
        }
    }
    
    func color(for health: ComponentHealth) -> Color {
        switch health {
        case .excellent: return success
        case .good: return info
        case .fair: return warning
        case .poor: return Color(hex: "FF6B00")
        case .replaceNow: return error
        }
    }
}
