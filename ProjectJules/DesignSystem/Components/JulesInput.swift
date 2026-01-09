//
//  JulesInput.swift
//  ProjectJules
//
//  Design System: Input Fields
//

import SwiftUI

// MARK: - Text Input
struct JulesTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var isSecure: Bool = false
    var icon: String? = nil
    var isError: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            HStack(spacing: JulesSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isFocused ? .julTerracotta : .julWarmGray)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.julInput)
                        .foregroundColor(.julWarmBlack)
                        .textContentType(textContentType)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.julInput)
                        .foregroundColor(.julWarmBlack)
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .focused($isFocused)
                }
            }
            .padding(JulesSpacing.md)
            .background(isFocused ? Color.white : Color.julInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.input)
                    .stroke(borderColor, lineWidth: isFocused || isError ? 1.5 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .font(.julCaption)
                    .foregroundColor(.julMutedRed)
                    .padding(.leading, JulesSpacing.xs)
            }
        }
    }

    private var borderColor: Color {
        if isError {
            return .julMutedRed
        } else if isFocused {
            return .julTerracotta
        }
        return .clear
    }
}

// MARK: - Text Area (Multi-line)
struct JulesTextArea: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 100
    var maxHeight: CGFloat = 200
    var characterLimit: Int? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .trailing, spacing: JulesSpacing.xs) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.julInput)
                        .foregroundColor(.julWarmGray)
                        .padding(.horizontal, JulesSpacing.md)
                        .padding(.top, JulesSpacing.md)
                }

                TextEditor(text: $text)
                    .font(.julInput)
                    .foregroundColor(.julWarmBlack)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, JulesSpacing.sm)
                    .padding(.vertical, JulesSpacing.sm)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        if let limit = characterLimit, newValue.count > limit {
                            text = String(newValue.prefix(limit))
                        }
                    }
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .background(isFocused ? Color.white : Color.julInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.input)
                    .stroke(isFocused ? Color.julTerracotta : .clear, lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))

            if let limit = characterLimit {
                Text("\(text.count)/\(limit)")
                    .font(.julCaption)
                    .foregroundColor(text.count >= limit ? .julMutedRed : .julWarmGray)
            }
        }
    }
}

// MARK: - Phone Input
struct JulesPhoneInput: View {
    @Binding var phoneNumber: String
    var countryCode: String = "+1"
    var isError: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            HStack(spacing: 0) {
                // Country Code
                Text(countryCode)
                    .font(.julInput)
                    .foregroundColor(.julWarmBlack)
                    .padding(.horizontal, JulesSpacing.md)
                    .padding(.vertical, JulesSpacing.md)
                    .background(Color.julDivider)

                // Phone Number
                TextField("(555) 123-4567", text: $phoneNumber)
                    .font(.julInput)
                    .foregroundColor(.julWarmBlack)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .padding(JulesSpacing.md)
                    .focused($isFocused)
                    .onChange(of: phoneNumber) { _, newValue in
                        phoneNumber = formatPhoneNumber(newValue)
                    }
            }
            .background(isFocused ? Color.white : Color.julInputBackground)
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.input)
                    .stroke(borderColor, lineWidth: isFocused || isError ? 1.5 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))

            if let errorMessage = errorMessage, isError {
                Text(errorMessage)
                    .font(.julCaption)
                    .foregroundColor(.julMutedRed)
                    .padding(.leading, JulesSpacing.xs)
            }
        }
    }

    private var borderColor: Color {
        if isError {
            return .julMutedRed
        } else if isFocused {
            return .julTerracotta
        }
        return .clear
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        let limited = String(digits.prefix(10))

        var result = ""
        for (index, digit) in limited.enumerated() {
            if index == 0 {
                result += "("
            }
            if index == 3 {
                result += ") "
            }
            if index == 6 {
                result += "-"
            }
            result += String(digit)
        }
        return result
    }
}

// MARK: - OTP Input
struct JulesOTPInput: View {
    @Binding var code: String
    var length: Int = 6
    var onComplete: ((String) -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            // Hidden TextField for input
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.01)
                .onChange(of: code) { _, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered.count <= length {
                        code = filtered
                    } else {
                        code = String(filtered.prefix(length))
                    }

                    if code.count == length {
                        onComplete?(code)
                    }
                }

            // Visual display
            HStack(spacing: JulesSpacing.sm) {
                ForEach(0..<length, id: \.self) { index in
                    OTPDigitBox(
                        digit: getDigit(at: index),
                        isActive: index == code.count && isFocused
                    )
                }
            }
            .onTapGesture {
                isFocused = true
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    private func getDigit(at index: Int) -> String? {
        guard index < code.count else { return nil }
        return String(code[code.index(code.startIndex, offsetBy: index)])
    }
}

struct OTPDigitBox: View {
    let digit: String?
    var isActive: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: JulesRadius.small)
                .fill(Color.julInputBackground)
                .frame(width: 48, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: JulesRadius.small)
                        .stroke(isActive ? Color.julTerracotta : .clear, lineWidth: 1.5)
                )

            if let digit = digit {
                Text(digit)
                    .font(.julTitle2)
                    .foregroundColor(.julWarmBlack)
            } else if isActive {
                Rectangle()
                    .fill(Color.julTerracotta)
                    .frame(width: 2, height: 24)
                    .opacity(isActive ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(), value: isActive)
            }
        }
    }
}

// MARK: - Selection Input
struct JulesSelectionButton: View {
    let title: String
    var subtitle: String? = nil
    var isSelected: Bool
    var style: SelectionStyle = .single
    let action: () -> Void

    enum SelectionStyle {
        case single  // Radio button style
        case multi   // Checkbox style
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: JulesSpacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)
                    }
                }

                Spacer()

                // Selection indicator
                ZStack {
                    if style == .single {
                        Circle()
                            .stroke(isSelected ? Color.julTerracotta : Color.julWarmGray, lineWidth: 2)
                            .frame(width: 22, height: 22)

                        if isSelected {
                            Circle()
                                .fill(Color.julTerracotta)
                                .frame(width: 12, height: 12)
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isSelected ? Color.julTerracotta : Color.julWarmGray, lineWidth: 2)
                            .frame(width: 22, height: 22)

                        if isSelected {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.julTerracotta)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
            }
            .padding(JulesSpacing.md)
            .background(isSelected ? Color.julTerracotta.opacity(0.08) : Color.julCard)
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.small)
                    .stroke(isSelected ? Color.julTerracotta : Color.julDivider, lineWidth: isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 24) {
            JulesTextField(
                placeholder: "Enter your name",
                text: .constant(""),
                icon: "person"
            )

            JulesTextField(
                placeholder: "Email",
                text: .constant("test@email.com"),
                icon: "envelope"
            )

            JulesTextField(
                placeholder: "Error state",
                text: .constant("bad input"),
                isError: true,
                errorMessage: "Please enter a valid value"
            )

            JulesPhoneInput(
                phoneNumber: .constant("5551234567")
            )

            JulesOTPInput(
                code: .constant("123")
            )

            JulesTextArea(
                placeholder: "Tell us about yourself...",
                text: .constant(""),
                characterLimit: 200
            )

            VStack(spacing: 12) {
                JulesSelectionButton(
                    title: "Women",
                    isSelected: true,
                    style: .multi,
                    action: {}
                )
                JulesSelectionButton(
                    title: "Men",
                    isSelected: false,
                    style: .multi,
                    action: {}
                )
            }
        }
        .padding()
    }
    .background(Color.julCream)
}
