//
//  BasicInfoView.swift
//  ProjectJules
//
//  Onboarding: Basic Info Collection
//

import SwiftUI

// MARK: - Basic Info View
struct BasicInfoView: View {
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
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("Let's start with the basics")
                            .font(.julTitle1)
                            .foregroundColor(.julWarmBlack)
                    }

                    // First Name
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("First name")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        JulesTextField(
                            placeholder: "Your first name",
                            text: $viewModel.firstName,
                            textContentType: .givenName
                        )
                    }

                    // Birthday
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("Birthday")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        DatePicker(
                            "",
                            selection: $viewModel.birthDate,
                            in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(JulesSpacing.md)
                        .background(Color.julInputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
                    }

                    // Gender
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("I am a...")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        HStack(spacing: JulesSpacing.sm) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                GenderButton(
                                    gender: gender,
                                    isSelected: viewModel.gender == gender
                                ) {
                                    viewModel.gender = gender
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.top, JulesSpacing.lg)
            }

            // Continue Button
            JulesButton(
                title: "Continue",
                style: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: !isValid
            ) {
                Task {
                    await viewModel.saveBasicInfo()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
        }
    }

    private var isValid: Bool {
        !viewModel.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        calculateAge() >= 18
    }

    private func calculateAge() -> Int {
        Calendar.current.dateComponents([.year], from: viewModel.birthDate, to: Date()).year ?? 0
    }
}

// MARK: - Gender Button
struct GenderButton: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(gender.displayName)
                .font(.julButton)
                .foregroundColor(isSelected ? .white : .julWarmBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, JulesSpacing.md)
                .background(isSelected ? Color.julWarmBlack : Color.julInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - More Details View
struct MoreDetailsView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    let heights: [Int] = Array(54...84) // 4'6" to 7'0"

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
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("A few more details")
                            .font(.julTitle1)
                            .foregroundColor(.julWarmBlack)

                        Text("These help Jules find better matches")
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }

                    // Height
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("Height")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        Menu {
                            ForEach(heights, id: \.self) { inches in
                                Button(formatHeight(inches)) {
                                    viewModel.heightInches = inches
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.heightInches != nil ? formatHeight(viewModel.heightInches!) : "Select height")
                                    .font(.julBody)
                                    .foregroundColor(viewModel.heightInches != nil ? .julWarmBlack : .julWarmGray)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.julWarmGray)
                            }
                            .padding(JulesSpacing.md)
                            .background(Color.julInputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
                        }
                    }

                    // Children
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("Do you have children?")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        HStack(spacing: JulesSpacing.sm) {
                            SelectButton(
                                title: "Yes",
                                isSelected: viewModel.hasChildren == true
                            ) {
                                viewModel.hasChildren = true
                            }

                            SelectButton(
                                title: "No",
                                isSelected: viewModel.hasChildren == false
                            ) {
                                viewModel.hasChildren = false
                            }
                        }
                    }

                    // Occupation
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("What do you do?")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)

                        JulesTextField(
                            placeholder: "Your occupation",
                            text: $viewModel.occupation,
                            textContentType: .jobTitle
                        )
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.top, JulesSpacing.lg)
            }

            // Continue Button
            JulesButton(
                title: "Continue",
                style: .primary,
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.saveMoreDetails()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
        }
    }

    private func formatHeight(_ inches: Int) -> String {
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }
}

// MARK: - Select Button
struct SelectButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.julButton)
                .foregroundColor(isSelected ? .white : .julWarmBlack)
                .frame(maxWidth: .infinity)
                .padding(.vertical, JulesSpacing.md)
                .background(isSelected ? Color.julWarmBlack : Color.julInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview("Basic Info") {
    BasicInfoView(viewModel: OnboardingViewModel())
        .background(Color.julCream)
}

#Preview("More Details") {
    MoreDetailsView(viewModel: OnboardingViewModel())
        .background(Color.julCream)
}
