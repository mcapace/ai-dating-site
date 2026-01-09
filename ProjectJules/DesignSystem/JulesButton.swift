//
//  JulesButton.swift
//  ProjectJules
//
//  Button component with multiple styles
//

import SwiftUI

enum ButtonStyle {
    case primary
    case secondary
    case outline
    case text
    case danger
}

struct JulesButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var icon: String? = nil
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.julButton())
                    }
                    Text(title)
                        .font(.julButton())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .julWarmBlack
        case .outline:
            return .julTerracotta
        case .text:
            return .julTerracotta
        case .danger:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .julTerracotta
        case .secondary:
            return .julCream
        case .outline:
            return .clear
        case .text:
            return .clear
        case .danger:
            return .julError
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline:
            return .julTerracotta
        default:
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        style == .outline ? 2 : 0
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        JulesButton(title: "Primary", style: .primary) {}
        JulesButton(title: "Secondary", style: .secondary) {}
        JulesButton(title: "Outline", style: .outline) {}
        JulesButton(title: "Text", style: .text) {}
        JulesButton(title: "Loading", style: .primary, isLoading: true) {}
        JulesButton(title: "Disabled", style: .primary, isDisabled: true) {}
    }
    .padding()
}

