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
                VStack(spacing: Spacing.lg) {
                    // Gender Preference
                    SectionCard(title: "I'm interested in") {
                        VStack(spacing: Spacing.sm) {
                            ForEach(["Women", "Men", "Non-binary", "Everyone"], id: \.self) { gender in
                                Button(action: {
                                    viewModel.toggleGenderPreference(gender)
                                }) {
                                    HStack {
                                        Text(gender)
                                            .font(.julBody())
                                            .foregroundColor(.julTextPrimary)
                                        Spacer()
                                        Image(systemName: viewModel.interestedIn.contains(gender) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(viewModel.interestedIn.contains(gender) ? .julTerracotta : .julTextSecondary)
                                    }
                                    .padding(Spacing.md)
                                    .background(Color.julCardBackground)
                                    .cornerRadius(Radius.md)
                                }
                            }
                        }
                    }

                    // Age Range
                    SectionCard(title: "Age range") {
                        VStack(spacing: Spacing.md) {
                            AgeRangeSelector(
                                minAge: $viewModel.minAge,
                                maxAge: $viewModel.maxAge
                            )

                            // Display values
                            HStack {
                                Text("\(viewModel.minAge)")
                                    .font(.julBody())
                                    .foregroundColor(.julTextPrimary)
                                Spacer()
                                Text("\(viewModel.maxAge)")
                                    .font(.julBody())
                                    .foregroundColor(.julTextPrimary)
                            }
                        }
                    }

                    // Height Preference
                    SectionCard(title: "Height preference") {
                        VStack(spacing: Spacing.md) {
                            HeightRangeSelector(
                                minHeight: $viewModel.minHeight,
                                maxHeight: $viewModel.maxHeight
                            )

                            HStack {
                                Text(formatHeight(viewModel.minHeight))
                                    .font(.julBody())
                                    .foregroundColor(.julTextPrimary)
                                Spacer()
                                Text(formatHeight(viewModel.maxHeight))
                                    .font(.julBody())
                                    .foregroundColor(.julTextPrimary)
                            }
                        }
                    }

                    // Children Preference
                    SectionCard(title: "Children") {
                        VStack(spacing: Spacing.sm) {
                            Button(action: {
                                viewModel.openToHasChildren.toggle()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Has children")
                                            .font(.julBody())
                                            .foregroundColor(.julTextPrimary)
                                        Text("Open to partners with children")
                                            .font(.julLabelSmall())
                                            .foregroundColor(.julTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: viewModel.openToHasChildren ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.openToHasChildren ? .julTerracotta : .julTextSecondary)
                                }
                                .padding(Spacing.md)
                                .background(Color.julCardBackground)
                                .cornerRadius(Radius.md)
                            }

                            Button(action: {
                                viewModel.openToWantsChildren.toggle()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Wants children")
                                            .font(.julBody())
                                            .foregroundColor(.julTextPrimary)
                                        Text("Open to partners who want children")
                                            .font(.julLabelSmall())
                                            .foregroundColor(.julTextSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: viewModel.openToWantsChildren ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.openToWantsChildren ? .julTerracotta : .julTextSecondary)
                                }
                                .padding(Spacing.md)
                                .background(Color.julCardBackground)
                                .cornerRadius(Radius.md)
                            }
                        }
                    }

                    // Distance
                    SectionCard(title: "Distance") {
                        VStack(spacing: Spacing.md) {
                            Slider(
                                value: $viewModel.maxDistance,
                                in: 1...50,
                                step: 1
                            )
                            .tint(.julTerracotta)

                            Text("Within \(Int(viewModel.maxDistance)) miles")
                                .font(.julBody())
                                .foregroundColor(.julTextSecondary)
                        }
                    }

                    // Dealbreakers
                    SectionCard(title: "Dealbreakers") {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("These are non-negotiables for you")
                                .font(.julLabelSmall())
                                .foregroundColor(.julTextSecondary)

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
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("Who I'm Looking For")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.julTextSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .font(.julButton())
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
                    .fill(Color.julBorder)
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
                    .fill(Color.julBorder)
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
                    .font(.julBody())
                    .foregroundColor(.julTextPrimary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .julTerracotta : .julTextSecondary)
            }
            .padding(Spacing.sm)
        }
    }
}

// MARK: - View Model
@MainActor
class EditPreferencesViewModel: ObservableObject {
    @Published var interestedIn: Set<String> = []
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
        interestedIn = ["Women"]
    }

    func toggleGenderPreference(_ gender: String) {
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
