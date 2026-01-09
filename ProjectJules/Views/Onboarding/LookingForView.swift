//
//  LookingForView.swift
//  ProjectJules
//
//  Onboarding: Who are you looking for?
//

import SwiftUI

struct LookingForView: View {
    @State private var selectedGenders: Set<String> = []
    @State private var ageMin: Int = 18
    @State private var ageMax: Int = 65
    
    let onContinue: () -> Void
    
    let genderOptions = ["Women", "Men", "Non-binary", "Everyone"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                Text("Who are you hoping to meet?")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xl)

                // Gender Preference
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Show me...")
                        .font(.julLabel())
                        .foregroundColor(.julTextSecondary)

                    VStack(spacing: Spacing.sm) {
                        ForEach(genderOptions, id: \.self) { gender in
                            HStack {
                                Text(gender)
                                    .font(.julBody())
                                    .foregroundColor(.julTextPrimary)
                                Spacer()
                                Image(systemName: selectedGenders.contains(gender) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedGenders.contains(gender) ? .julTerracotta : .julBorder)
                            }
                            .padding(Spacing.md)
                            .background(Color.julCardBackground)
                            .cornerRadius(Radius.md)
                            .onTapGesture {
                                if selectedGenders.contains(gender) {
                                    selectedGenders.remove(gender)
                                } else {
                                    selectedGenders.insert(gender)
                                }
                            }
                        }
                    }
                }

                // Age Range
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Text("Age range")
                            .font(.julLabel())
                            .foregroundColor(.julTextSecondary)

                        Spacer()

                        Text("\(ageMin) - \(ageMax)")
                            .font(.julBody())
                            .foregroundColor(.julTextPrimary)
                    }

                    // Simple Slider
                    VStack(spacing: Spacing.sm) {
                        HStack {
                            Text("\(ageMin)")
                            Slider(value: Binding(
                                get: { Double(ageMin) },
                                set: { ageMin = min(Int($0), ageMax - 1) }
                            ), in: 18...65)
                        }
                        
                        HStack {
                            Text("\(ageMax)")
                            Slider(value: Binding(
                                get: { Double(ageMax) },
                                set: { ageMax = max(Int($0), ageMin + 1) }
                            ), in: 18...65)
                        }
                    }
                }
                .padding(Spacing.md)
                .background(Color.julCardBackground)
                .cornerRadius(Radius.md)
                
                JulesButton(
                    title: "Continue",
                    style: .primary,
                    isDisabled: selectedGenders.isEmpty
                ) {
                    onContinue()
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}

// MARK: - Preview
#Preview {
    LookingForView(onContinue: {})
        .background(Color.julBackground)
}
