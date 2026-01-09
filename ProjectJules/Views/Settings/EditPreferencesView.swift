//
//  EditPreferencesView.swift
//  ProjectJules
//
//  Preferences Editing - Who I'm Looking For
//

import SwiftUI

struct EditPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditPreferencesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: JulesSpacing.lg) {
                    // Gender Preference
                    SectionCard(title: "I'm interested in") {
                        VStack(spacing: JulesSpacing.sm) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                JulesSelectionButton(
                                    title: gender.displayName,
                                    isSelected: viewModel.interestedIn.contains(gender),
                                    style: .multi
                                ) {
                                    viewModel.toggleGenderPreference(gender)
                                }
                            }
                        }
                    }

                    // Age Range
                    SectionCard(title: "Age range") {
                        VStack(spacing: JulesSpacing.md) {
                            AgeRangeSelector(
                                minAge: $viewModel.minAge,
                                maxAge: $viewModel.maxAge
                            )

                            // Display values
                            HStack {
                                Text("\(viewModel.minAge)")
                                    .font(.julBody)
                                    .foregroundColor(.julWarmBlack)
                                Spacer()
                                Text("\(viewModel.maxAge)")
                                    .font(.julBody)
                                    .foregroundColor(.julWarmBlack)
                            }
                        }
                    }

                    // Height Preference
                    SectionCard(title: "Height preference") {
                        VStack(spacing: JulesSpacing.md) {
                            HeightRangeSelector(
                                minHeight: $viewModel.minHeight,
                                maxHeight: $viewModel.maxHeight
                            )

                            HStack {
                                Text(formatHeight(viewModel.minHeight))
                                    .font(.julBody)
                                    .foregroundColor(.julWarmBlack)
                                Spacer()
                                Text(formatHeight(viewModel.maxHeight))
                                    .font(.julBody)
                                    .foregroundColor(.julWarmBlack)
                            }
                        }
                    }

                    // Children Preference
                    SectionCard(title: "Children") {
                        VStack(spacing: JulesSpacing.sm) {
                            JulesSelectionButton(
                                title: "Has children",
                                subtitle: "Open to partners with children",
                                isSelected: viewModel.openToHasChildren,
                                style: .multi
                            ) {
                                viewModel.openToHasChildren.toggle()
                            }

                            JulesSelectionButton(
                                title: "Wants children",
                                subtitle: "Open to partners who want children",
                                isSelected: viewModel.openToWantsChildren,
                                style: .multi
                            ) {
                                viewModel.openToWantsChildren.toggle()
                            }
                        }
                    }

                    // Distance
                    SectionCard(title: "Distance") {
                        VStack(spacing: JulesSpacing.md) {
                            Slider(
                                value: $viewModel.maxDistance,
                                in: 1...50,
                                step: 1
                            )
                            .tint(.julTerracotta)

                            Text("Within \(Int(viewModel.maxDistance)) miles")
                                .font(.julBody)
                                .foregroundColor(.julWarmGray)
                        }
                    }

                    // Dealbreakers
                    SectionCard(title: "Dealbreakers") {
                        VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                            Text("These are non-negotiables for you")
                                .font(.julCaption)
                                .foregroundColor(.julWarmGray)

                            ForEach(viewModel.availableDealbreakers, id: \.self) { dealbreaker in
                                DealbreakerToggle(
                                    title: dealbreaker,
                                    isSelected: viewModel.dealbreakers.contains(dealbreaker)
                                ) {
                                    viewModel.toggleDealbreaker(dealbreaker)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("Who I'm Looking For")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.julWarmGray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .font(.julButton)
                    .foregroundColor(.julTerracotta)
                }
            }
        }
    }

    private func formatHeight(_ inches: Int) -> String {
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }
}

// MARK: - Age Range Selector
struct AgeRangeSelector: View {
    @Binding var minAge: Int
    @Binding var maxAge: Int

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.julDivider)
                    .frame(height: 4)

                // Selected range
                Rectangle()
                    .fill(Color.julTerracotta)
                    .frame(
                        width: CGFloat(maxAge - minAge) / CGFloat(82 - 18) * geometry.size.width,
                        height: 4
                    )
                    .offset(x: CGFloat(minAge - 18) / CGFloat(82 - 18) * geometry.size.width)

                // Min thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .offset(x: CGFloat(minAge - 18) / CGFloat(82 - 18) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newMin = Int(value.location.x / geometry.size.width * 64) + 18
                                minAge = max(18, min(newMin, maxAge - 1))
                            }
                    )

                // Max thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .offset(x: CGFloat(maxAge - 18) / CGFloat(82 - 18) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newMax = Int(value.location.x / geometry.size.width * 64) + 18
                                maxAge = min(82, max(newMax, minAge + 1))
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}

// MARK: - Height Range Selector
struct HeightRangeSelector: View {
    @Binding var minHeight: Int
    @Binding var maxHeight: Int

    private let minInches = 54  // 4'6"
    private let maxInches = 84  // 7'0"

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color.julDivider)
                    .frame(height: 4)

                // Selected range
                Rectangle()
                    .fill(Color.julTerracotta)
                    .frame(
                        width: CGFloat(maxHeight - minHeight) / CGFloat(maxInches - minInches) * geometry.size.width,
                        height: 4
                    )
                    .offset(x: CGFloat(minHeight - minInches) / CGFloat(maxInches - minInches) * geometry.size.width)

                // Min thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .offset(x: CGFloat(minHeight - minInches) / CGFloat(maxInches - minInches) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let range = maxInches - minInches
                                let newMin = Int(value.location.x / geometry.size.width * CGFloat(range)) + minInches
                                minHeight = max(minInches, min(newMin, maxHeight - 1))
                            }
                    )

                // Max thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.15), radius: 4)
                    .offset(x: CGFloat(maxHeight - minInches) / CGFloat(maxInches - minInches) * geometry.size.width - 12)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let range = maxInches - minInches
                                let newMax = Int(value.location.x / geometry.size.width * CGFloat(range)) + minInches
                                maxHeight = min(maxInches, max(newMax, minHeight + 1))
                            }
                    )
            }
        }
        .frame(height: 24)
    }
}

// MARK: - Dealbreaker Toggle
struct DealbreakerToggle: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.julBody)
                    .foregroundColor(.julWarmBlack)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .julTerracotta : .julWarmGray)
            }
            .padding(JulesSpacing.sm)
        }
    }
}

// MARK: - View Model
@MainActor
class EditPreferencesViewModel: ObservableObject {
    @Published var interestedIn: Set<Gender> = []
    @Published var minAge = 25
    @Published var maxAge = 45
    @Published var minHeight = 60  // 5'0"
    @Published var maxHeight = 78  // 6'6"
    @Published var openToHasChildren = true
    @Published var openToWantsChildren = true
    @Published var maxDistance: Double = 25
    @Published var dealbreakers: Set<String> = []

    let availableDealbreakers = [
        "Non-smoker",
        "Doesn't do drugs",
        "Social drinker or less",
        "Has a job",
        "College educated",
        "No kids",
        "Wants kids"
    ]

    init() {
        loadPreferences()
    }

    private func loadPreferences() {
        // TODO: Load from UserService
        interestedIn = [.woman]
    }

    func toggleGenderPreference(_ gender: Gender) {
        if interestedIn.contains(gender) {
            interestedIn.remove(gender)
        } else {
            interestedIn.insert(gender)
        }
    }

    func toggleDealbreaker(_ dealbreaker: String) {
        if dealbreakers.contains(dealbreaker) {
            dealbreakers.remove(dealbreaker)
        } else {
            dealbreakers.insert(dealbreaker)
        }
    }

    func save() async {
        // TODO: Save to UserService
    }
}

// MARK: - Preview
#Preview {
    EditPreferencesView()
}
