//
//  JulesInput.swift
//  ProjectJules
//
//  Input components: text fields, phone, OTP
//

import SwiftUI

struct JulesTextField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var errorMessage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.julLabel())
                .foregroundColor(.julTextPrimary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(.julBody())
            .foregroundColor(.julTextPrimary)
            .padding(Spacing.md)
            .background(Color.julCream)
            .cornerRadius(Radius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.md)
                    .stroke(errorMessage != nil ? Color.julError : Color.julBorder, lineWidth: 1)
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.julLabelSmall())
                    .foregroundColor(.julError)
            }
        }
    }
}

struct PhoneInputView: View {
    @Binding var phoneNumber: String
    var onSendCode: () -> Void
    @State private var formattedPhone: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Phone Number")
                .font(.julHeadline3())
                .foregroundColor(.julTextPrimary)
            
            Text("We'll send you a verification code")
                .font(.julBodySmall())
                .foregroundColor(.julTextSecondary)
            
            JulesTextField(
                title: "",
                text: $formattedPhone,
                placeholder: "(555) 123-4567",
                keyboardType: .phonePad
            )
            .onChange(of: formattedPhone) { oldValue, newValue in
                phoneNumber = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                formattedPhone = formatPhoneNumber(phoneNumber)
            }
            
            JulesButton(title: "Send Code", style: .primary) {
                onSendCode()
            }
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let cleaned = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleaned.count >= 10 {
            let areaCode = String(cleaned.prefix(3))
            let firstPart = String(cleaned.dropFirst(3).prefix(3))
            let lastPart = String(cleaned.dropFirst(6).prefix(4))
            return "(\(areaCode)) \(firstPart)-\(lastPart)"
        }
        return cleaned
    }
}

struct OTPInputView: View {
    @Binding var code: String
    let digitCount: Int = 6
    @FocusState private var focusedField: Int?
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<digitCount, id: \.self) { index in
                TextField("", text: Binding(
                    get: {
                        index < code.count ? String(code[code.index(code.startIndex, offsetBy: index)]) : ""
                    },
                    set: { newValue in
                        if newValue.count <= 1 {
                            if index < code.count {
                                let startIndex = code.index(code.startIndex, offsetBy: index)
                                code.replaceSubrange(startIndex..<code.index(after: startIndex), with: newValue)
                            } else if code.count == index {
                                code += newValue
                            }
                            
                            if !newValue.isEmpty && index < digitCount - 1 {
                                focusedField = index + 1
                            }
                        }
                    }
                ))
                .font(.julHeadline2())
                .multilineTextAlignment(.center)
                .frame(width: 50, height: 60)
                .background(Color.julCream)
                .cornerRadius(Radius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.md)
                        .stroke(focusedField == index ? Color.julTerracotta : Color.julBorder, lineWidth: 2)
                )
                .focused($focusedField, equals: index)
                .keyboardType(.numberPad)
            }
        }
    }
}

#Preview {
    VStack(spacing: Spacing.xl) {
        JulesTextField(title: "Name", text: .constant(""), placeholder: "Enter your name")
        PhoneInputView(phoneNumber: .constant("")) {}
        OTPInputView(code: .constant(""))
    }
    .padding()
}

