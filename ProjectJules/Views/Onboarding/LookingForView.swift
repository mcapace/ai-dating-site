//
//  LookingForView.swift
//  ProjectJules
//
//  Onboarding: Who are you looking for?
//

import SwiftUI

struct LookingForView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                JulesIconButton(icon: "arrow.left", size: 44, backgroundColor: .clear) {
                    viewModel.previousStep()
                }
                Spacer()
            }
            .padding(.horizontal, JulesSpacing.screen)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: JulesSpacing.xl) {
                    // Title
                    Text("Who are you hoping to meet?")
                        .font(.julTitle1)
                        .foregroundColor(.julWarmBlack)

                    // Gender Preference
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("Show me...")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        VStack(spacing: JulesSpacing.sm) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                JulesSelectionButton(
                                    title: gender.displayName,
                                    isSelected: viewModel.genderPreference.contains(gender),
                                    style: .multi
                                ) {
                                    if viewModel.genderPreference.contains(gender) {
                                        viewModel.genderPreference.remove(gender)
                                    } else {
                                        viewModel.genderPreference.insert(gender)
                                    }
                                }
                            }
                        }
                    }

                    // Age Range
                    VStack(alignment: .leading, spacing: JulesSpacing.md) {
                        HStack {
                            Text("Age range")
                                .font(.julBodySmall)
                                .foregroundColor(.julWarmGray)

                            Spacer()

                            Text("\(Int(viewModel.ageMin)) - \(Int(viewModel.ageMax))")
                                .font(.julBody)
                                .foregroundColor(.julWarmBlack)
                        }

                        // Custom Range Slider
                        AgeRangeSlider(
                            minValue: $viewModel.ageMin,
                            maxValue: $viewModel.ageMax,
                            range: 18...65
                        )
                    }
                    .padding(JulesSpacing.md)
                    .background(Color.julCard)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.top, JulesSpacing.lg)
            }

            // Continue Button
            JulesButton(
                title: "Continue",
                style: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.genderPreference.isEmpty
            ) {
                Task {
                    await viewModel.savePreferences()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
        }
    }
}

// MARK: - Age Range Slider
struct AgeRangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.julDivider)
                    .frame(height: 4)

                // Selected Range
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.julTerracotta)
                    .frame(
                        width: CGFloat((maxValue - minValue) / (range.upperBound - range.lowerBound)) * geometry.size.width,
                        height: 4
                    )
                    .offset(x: CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width)

                // Min Thumb
                Circle()
                    .fill(Color.julWarmBlack)
                    .frame(width: 24, height: 24)
                    .offset(x: CGFloat((minValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * (geometry.size.width - 24))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(value.location.x / geometry.size.width)
                                minValue = min(max(newValue, range.lowerBound), maxValue - 1)
                            }
                    )

                // Max Thumb
                Circle()
                    .fill(Color.julWarmBlack)
                    .frame(width: 24, height: 24)
                    .offset(x: CGFloat((maxValue - range.lowerBound) / (range.upperBound - range.lowerBound)) * (geometry.size.width - 24))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(value.location.x / geometry.size.width)
                                maxValue = max(min(newValue, range.upperBound), minValue + 1)
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}

// MARK: - Preview
#Preview {
    LookingForView(viewModel: OnboardingViewModel())
        .background(Color.julCream)
}
