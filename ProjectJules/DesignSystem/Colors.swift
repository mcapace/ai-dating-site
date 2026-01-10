//
//  Colors.swift
//  ProjectJules
//
//  Design System: Color Palette
//

import SwiftUI

// MARK: - Brand Colors
extension Color {

    // MARK: Core Colors

    /// Warm off-white background - #FAF7F2
    static let julCream = Color(hex: "FAF7F2")

    /// Warm black for primary text - #1A1815
    static let julWarmBlack = Color(hex: "1A1815")

    /// Primary accent - Terracotta - #C4775A
    static let julTerracotta = Color(hex: "C4775A")

    /// Secondary accent - Sage - #7D8B6A
    static let julSage = Color(hex: "7D8B6A")

    /// Secondary text - Warm Gray - #8A8580
    static let julWarmGray = Color(hex: "8A8580")

    // MARK: Extended Palette

    /// Light terracotta for hover/pressed states - #D4917A
    static let julTerracottaLight = Color(hex: "D4917A")

    /// Dark terracotta for dark mode - #A65F45
    static let julTerracottaDark = Color(hex: "A65F45")

    /// Warm gold for highlights - #D4A853
    static let julGold = Color(hex: "D4A853")

    /// Soft blue for info states - #5A8BC4
    static let julSoftBlue = Color(hex: "5A8BC4")

    /// Muted red for errors - #C45A5A
    static let julMutedRed = Color(hex: "C45A5A")

    // MARK: Surface Colors

    /// Card background - pure white
    static let julCard = Color.white

    /// Input field background - #F5F2ED
    static let julInputBackground = Color(hex: "F5F2ED")

    /// Divider color - #E8E4DF
    static let julDivider = Color(hex: "E8E4DF")

    /// Subtle background tint - #F7F4EF
    static let julSurfaceSubtle = Color(hex: "F7F4EF")

    // MARK: Dark Mode Colors

    /// Dark mode background - #1A1815
    static let julDarkBackground = Color(hex: "1A1815")

    /// Dark mode surface - #252220
    static let julDarkSurface = Color(hex: "252220")

    /// Dark mode card - #2D2A27
    static let julDarkCard = Color(hex: "2D2A27")

    /// Dark mode muted text - #9A9590
    static let julDarkMuted = Color(hex: "9A9590")

    // MARK: Semantic Colors

    static let julSuccess = Color.julSage
    static let julWarning = Color.julGold
    static let julError = Color.julMutedRed
    static let julInfo = Color.julSoftBlue
}

// MARK: - Adaptive Colors (Light/Dark Mode)
extension Color {

    /// Primary background color - adapts to color scheme
    static var julBackground: Color {
        Color("Background", bundle: nil)
    }

    /// Primary text color - adapts to color scheme
    static var julText: Color {
        Color("Text", bundle: nil)
    }

    /// Secondary text color - adapts to color scheme
    static var julTextSecondary: Color {
        Color("TextSecondary", bundle: nil)
    }

    /// Primary accent - adapts to color scheme
    static var julAccent: Color {
        Color("Accent", bundle: nil)
    }
}

// MARK: - Gradients
extension LinearGradient {

    /// Warm spark gradient for special moments
    static let julSparkGradient = LinearGradient(
        colors: [Color(hex: "F7E6DC"), Color(hex: "E6D5C8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle shimmer for loading states
    static let julShimmerGradient = LinearGradient(
        colors: [
            Color(hex: "F5F2ED"),
            Color.white,
            Color(hex: "F5F2ED")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Premium gradient for special elements
    static let julPremiumGradient = LinearGradient(
        colors: [Color(hex: "C4775A"), Color(hex: "D4A853")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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

// MARK: - Color Scheme Helper
extension View {
    @ViewBuilder
    func adaptiveBackground() -> some View {
        self.background(Color.julCream)
    }
}

