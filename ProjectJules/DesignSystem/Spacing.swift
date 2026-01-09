//
//  Spacing.swift
//  ProjectJules
//
//  Spacing scale, radii, and shadows
//

import SwiftUI

struct Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

struct Radius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

struct Shadow {
    static let sm = ShadowStyle(
        color: Color.julShadow,
        radius: 2,
        x: 0,
        y: 1
    )
    
    static let md = ShadowStyle(
        color: Color.julShadow,
        radius: 4,
        x: 0,
        y: 2
    )
    
    static let lg = ShadowStyle(
        color: Color.julShadow,
        radius: 8,
        x: 0,
        y: 4
    )
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    func julShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

