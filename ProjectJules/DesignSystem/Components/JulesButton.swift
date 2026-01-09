//
//  JulesButton.swift
//  ProjectJules
//
//  Design System: Buttons
//

import SwiftUI

// MARK: - Button Styles
enum JulesButtonStyle {
    case primary      // Solid warm black
    case secondary    // Outline
    case accent       // Terracotta (special actions)
    case ghost        // Text only
    case destructive  // Red outline/text
}

enum JulesButtonSize {
    case large   // 52pt height
    case medium  // 44pt height
    case small   // 36pt height
}

// MARK: - Jules Button
struct JulesButton: View {
    let title: String
    let style: JulesButtonStyle
    var size: JulesButtonSize = .large
    var icon: String? = nil
    var iconPosition: IconPosition = .leading
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = true
    let action: () -> Void

    enum IconPosition {
        case leading
        case trailing
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                action()
            }
        }) {
            HStack(spacing: JulesSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.9)
                } else {
                    if let icon = icon, iconPosition == .leading {
                        Image(systemName: icon)
                            .font(.system(size: iconSize, weight: .medium))
                    }

                    Text(title)
                        .font(.julButton)

                    if let icon = icon, iconPosition == .trailing {
                        Image(systemName: icon)
                            .font(.system(size: iconSize, weight: .medium))
                    }
                }
            }
            .foregroundColor(textColor)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: buttonHeight)
            .padding(.horizontal, JulesSpacing.lg)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }

    // MARK: - Computed Properties

    private var buttonHeight: CGFloat {
        switch size {
        case .large: return JulesSize.buttonHeight
        case .medium: return JulesSize.buttonHeightSmall
        case .small: return JulesSize.buttonHeightMini
        }
    }

    private var cornerRadius: CGFloat {
        buttonHeight / 2 // Pill shape
    }

    private var iconSize: CGFloat {
        switch size {
        case .large: return 18
        case .medium: return 16
        case .small: return 14
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isPressed ? Color.julWarmBlack.opacity(0.85) : .julWarmBlack
        case .accent:
            return isPressed ? Color.julTerracotta.opacity(0.85) : .julTerracotta
        case .secondary, .ghost, .destructive:
            return isPressed ? Color.julInputBackground : .clear
        }
    }

    private var textColor: Color {
        switch style {
        case .primary:
            return .julCream
        case .accent:
            return .white
        case .secondary:
            return .julWarmBlack
        case .ghost:
            return .julWarmBlack
        case .destructive:
            return .julMutedRed
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .accent, .ghost:
            return .clear
        case .secondary:
            return .julWarmGray
        case .destructive:
            return .julMutedRed
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .secondary, .destructive:
            return 1.5
        default:
            return 0
        }
    }
}

// MARK: - Press Events Modifier
struct PressEventsModifier: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Quick Action Button (Icon Only)
struct JulesIconButton: View {
    let icon: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var backgroundColor: Color = .julInputBackground
    var iconColor: Color = .julWarmBlack
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Text Button (Link Style)
struct JulesTextButton: View {
    let title: String
    var color: Color = .julTerracotta
    var font: Font = .julBody
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundColor(color)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        JulesButton(title: "Yes, intro me", style: .primary) {}

        JulesButton(title: "Not for me", style: .secondary) {}

        JulesButton(title: "Start Spark Exchange", style: .accent, icon: "sparkles") {}

        JulesButton(title: "Skip", style: .ghost) {}

        JulesButton(title: "Delete Account", style: .destructive) {}

        JulesButton(title: "Loading...", style: .primary, isLoading: true) {}

        JulesButton(title: "Disabled", style: .primary, isDisabled: true) {}

        HStack(spacing: 16) {
            JulesIconButton(icon: "arrow.left") {}
            JulesIconButton(icon: "xmark") {}
            JulesIconButton(icon: "heart.fill", iconColor: .julTerracotta) {}
        }
    }
    .padding()
    .background(Color.julCream)
}
