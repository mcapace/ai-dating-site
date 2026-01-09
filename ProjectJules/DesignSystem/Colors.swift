//
//  Colors.swift
//  ProjectJules
//
//  Brand color palette
//

import SwiftUI

extension Color {
    // MARK: - Brand Colors
    static let julCream = Color(red: 0.98, green: 0.96, blue: 0.94)
    static let julWarmBlack = Color(red: 0.15, green: 0.13, blue: 0.12)
    static let julTerracotta = Color(red: 0.85, green: 0.45, blue: 0.35)
    static let julSage = Color(red: 0.65, green: 0.75, blue: 0.65)
    
    // MARK: - Semantic Colors
    static let julBackground = julCream
    static let julTextPrimary = julWarmBlack
    static let julTextSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
    static let julAccent = julTerracotta
    static let julSuccess = julSage
    static let julError = Color(red: 0.9, green: 0.3, blue: 0.3)
    static let julWarning = Color(red: 0.95, green: 0.7, blue: 0.2)
    
    // MARK: - UI Colors
    static let julCardBackground = Color.white
    static let julBorder = Color(red: 0.9, green: 0.9, blue: 0.9)
    static let julShadow = Color.black.opacity(0.1)
}

