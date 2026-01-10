//
//  Spacing.swift
//  ProjectJules
//
//  Design System: Spacing & Layout
//

import SwiftUI

// MARK: - Spacing Scale
enum JulesSpacing {
    /// 4pt - Minimal spacing (icon padding)
    static let xxs: CGFloat = 4

    /// 8pt - Tight spacing (related elements)
    static let xs: CGFloat = 8

    /// 12pt - Compact spacing (list items)
    static let sm: CGFloat = 12

    /// 16pt - Standard spacing (component padding)
    static let md: CGFloat = 16

    /// 20pt - Screen margins
    static let screen: CGFloat = 20

    /// 24pt - Comfortable spacing (section gaps)
    static let lg: CGFloat = 24

    /// 32pt - Spacious spacing (major sections)
    static let xl: CGFloat = 32

    /// 48pt - Generous spacing (screen sections)
    static let xxl: CGFloat = 48

    /// 64pt - Hero spacing (top margins, breathing room)
    static let hero: CGFloat = 64
}

// MARK: - Corner Radii
enum JulesRadius {
    /// 8pt - Small radius (buttons, inputs, tags)
    static let small: CGFloat = 8

    /// 12pt - Input fields
    static let input: CGFloat = 12

    /// 16pt - Medium radius (cards, images)
    static let medium: CGFloat = 16

    /// 24pt - Large radius (modal sheets, featured cards)
    static let large: CGFloat = 24

    /// 26pt - Pill buttons (height 52 / 2)
    static let pill: CGFloat = 26

    /// Full circle
    static let full: CGFloat = .infinity
}

// MARK: - Component Sizes
enum JulesSize {
    // Buttons
    static let buttonHeight: CGFloat = 52
    static let buttonHeightSmall: CGFloat = 44
    static let buttonHeightMini: CGFloat = 36

    // Avatars
    static let avatarSmall: CGFloat = 32
    static let avatarMedium: CGFloat = 44
    static let avatarLarge: CGFloat = 64
    static let avatarXLarge: CGFloat = 80
    static let avatarHero: CGFloat = 120

    // Icons
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let iconXLarge: CGFloat = 32

    // Cards
    static let cardPadding: CGFloat = 20

    // Photos
    static let photoGridSpacing: CGFloat = 4
    static let photoGridColumns: Int = 3
}

// MARK: - Shadows
struct JulesShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    /// Subtle elevation for cards
    static let card = JulesShadow(
        color: Color.julWarmBlack.opacity(0.08),
        radius: 24,
        x: 0,
        y: 4
    )

    /// Slightly more prominent shadow
    static let elevated = JulesShadow(
        color: Color.julWarmBlack.opacity(0.12),
        radius: 32,
        x: 0,
        y: 8
    )

    /// Soft shadow for buttons on hover/press
    static let button = JulesShadow(
        color: Color.julWarmBlack.opacity(0.06),
        radius: 8,
        x: 0,
        y: 2
    )

    /// No shadow
    static let none = JulesShadow(
        color: .clear,
        radius: 0,
        x: 0,
        y: 0
    )
}

// MARK: - Shadow Modifier
extension View {
    func julesShadow(_ shadow: JulesShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - Layout Helpers
extension View {
    /// Standard screen padding (20pt horizontal)
    func screenPadding() -> some View {
        self.padding(.horizontal, JulesSpacing.screen)
    }

    /// Card padding (20pt all around)
    func cardPadding() -> some View {
        self.padding(JulesSize.cardPadding)
    }

    /// Section spacing (24pt vertical)
    func sectionSpacing() -> some View {
        self.padding(.vertical, JulesSpacing.lg)
    }
}

// MARK: - Safe Area Helpers
struct SafeAreaHelper {
    static var topInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }

    static var bottomInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

