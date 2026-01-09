//
//  EditNeighborhoodsView.swift
//  ProjectJules
//
//  Edit Dating Neighborhoods
//

import SwiftUI

struct EditNeighborhoodsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditNeighborhoodsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Selected count
                HStack {
                    Text("\(viewModel.selectedNeighborhoods.count) selected")
                        .font(.julBody())
                        .foregroundColor(.julTextSecondary)

                    Spacer()

                    if viewModel.selectedNeighborhoods.count > 0 {
                        Button("Clear all") {
                            viewModel.clearAll()
                        }
                        .font(.julBodySmall())
                        .foregroundColor(.julTerracotta)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(Color.julCream)

                Divider()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // City selector (for future multi-city support)
                        if viewModel.availableCities.count > 1 {
                            CitySelector(
                                cities: viewModel.availableCities,
                                selectedCity: $viewModel.selectedCity
                            )
                        }

                        // Neighborhood groups
                        ForEach(viewModel.neighborhoodGroups, id: \.name) { group in
                            NeighborhoodGroupSection(
                                group: group,
                                selectedNeighborhoods: $viewModel.selectedNeighborhoods
                            )
                        }

                        // Info text
                        InfoCard(
                            icon: "info.circle",
                            text: "Jules will look for matches who live in or frequently visit these neighborhoods."
                        )
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                }
                .background(Color.julCream)
            }
            .navigationTitle("Where I Want to Date")
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
                    .disabled(viewModel.selectedNeighborhoods.isEmpty)
                }
            }
        }
    }
}

// MARK: - City Selector
struct CitySelector: View {
    let cities: [String]
    @Binding var selectedCity: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("City")
                .font(.julLabelSmall())
                .foregroundColor(.julTextSecondary)

            Menu {
                ForEach(cities, id: \.self) { city in
                    Button(city) {
                        selectedCity = city
                    }
                }
            } label: {
                HStack {
                    Text(selectedCity ?? "Select city")
                        .font(.julBody())
                        .foregroundColor(selectedCity != nil ? .julTextPrimary : .julTextSecondary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.julTextSecondary)
                }
                .padding(Spacing.md)
                .background(Color.julCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            }
        }
    }
}

// MARK: - Neighborhood Group Section
struct NeighborhoodGroupSection: View {
    let group: NeighborhoodGroup
    @Binding var selectedNeighborhoods: Set<String>

    @State private var isExpanded = true

    var selectedCount: Int {
        group.neighborhoods.filter { selectedNeighborhoods.contains($0.id) }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Group Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(group.name)
                        .font(.julHeadline3())
                        .foregroundColor(.julTextPrimary)

                    if selectedCount > 0 {
                        Text("(\(selectedCount))")
                            .font(.julLabelSmall())
                            .foregroundColor(.julTerracotta)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.julTextSecondary)
                }
            }

            // Neighborhoods
            if isExpanded {
                FlowLayout(spacing: Spacing.xs) {
                    ForEach(group.neighborhoods) { neighborhood in
                        NeighborhoodChip(
                            neighborhood: neighborhood,
                            isSelected: selectedNeighborhoods.contains(neighborhood.id)
                        ) {
                            toggleSelection(neighborhood.id)
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.julCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }

    private func toggleSelection(_ id: String) {
        if selectedNeighborhoods.contains(id) {
            selectedNeighborhoods.remove(id)
        } else {
            selectedNeighborhoods.insert(id)
        }
    }
}

// MARK: - Neighborhood Chip
struct NeighborhoodChip: View {
    let neighborhood: SimpleNeighborhood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(neighborhood.name)
                .font(.julBody())
                .foregroundColor(isSelected ? .white : .julTextPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.julTextPrimary : Color.julCream)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.julTerracotta)

            Text(text)
                .font(.julLabelSmall())
                .foregroundColor(.julTextSecondary)
                .lineSpacing(3)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.julTerracotta.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

// MARK: - Simple Neighborhood Model (for this view only)
struct SimpleNeighborhood: Identifiable {
    let id: String
    let cityId: String
    let name: String
    let isActive: Bool
}

// MARK: - Neighborhood Group Model
struct NeighborhoodGroup {
    let name: String
    let neighborhoods: [SimpleNeighborhood]
}

// MARK: - View Model
@MainActor
class EditNeighborhoodsViewModel: ObservableObject {
    @Published var availableCities: [String] = []
    @Published var selectedCity: String?
    @Published var neighborhoodGroups: [NeighborhoodGroup] = []
    @Published var selectedNeighborhoods: Set<String> = []

    init() {
        loadData()
    }

    private func loadData() {
        // For now, only NYC is available
        availableCities = ["New York City"]
        selectedCity = "New York City"
        
        // NYC neighborhoods grouped by area
        neighborhoodGroups = [
            NeighborhoodGroup(
                name: "Manhattan - Downtown",
                neighborhoods: [
                    SimpleNeighborhood(id: "tribeca", cityId: "nyc", name: "Tribeca", isActive: true),
                    SimpleNeighborhood(id: "soho", cityId: "nyc", name: "SoHo", isActive: true),
                    SimpleNeighborhood(id: "west_village", cityId: "nyc", name: "West Village", isActive: true),
                    SimpleNeighborhood(id: "east_village", cityId: "nyc", name: "East Village", isActive: true),
                    SimpleNeighborhood(id: "lower_east_side", cityId: "nyc", name: "Lower East Side", isActive: true),
                    SimpleNeighborhood(id: "financial_district", cityId: "nyc", name: "Financial District", isActive: true),
                    SimpleNeighborhood(id: "chelsea", cityId: "nyc", name: "Chelsea", isActive: true),
                    SimpleNeighborhood(id: "greenwich_village", cityId: "nyc", name: "Greenwich Village", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Manhattan - Midtown",
                neighborhoods: [
                    SimpleNeighborhood(id: "midtown_east", cityId: "nyc", name: "Midtown East", isActive: true),
                    SimpleNeighborhood(id: "midtown_west", cityId: "nyc", name: "Midtown West", isActive: true),
                    SimpleNeighborhood(id: "hells_kitchen", cityId: "nyc", name: "Hell's Kitchen", isActive: true),
                    SimpleNeighborhood(id: "gramercy", cityId: "nyc", name: "Gramercy", isActive: true),
                    SimpleNeighborhood(id: "flatiron", cityId: "nyc", name: "Flatiron", isActive: true),
                    SimpleNeighborhood(id: "murray_hill", cityId: "nyc", name: "Murray Hill", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Manhattan - Uptown",
                neighborhoods: [
                    SimpleNeighborhood(id: "upper_east_side", cityId: "nyc", name: "Upper East Side", isActive: true),
                    SimpleNeighborhood(id: "upper_west_side", cityId: "nyc", name: "Upper West Side", isActive: true),
                    SimpleNeighborhood(id: "harlem", cityId: "nyc", name: "Harlem", isActive: true),
                    SimpleNeighborhood(id: "morningside_heights", cityId: "nyc", name: "Morningside Heights", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Brooklyn",
                neighborhoods: [
                    SimpleNeighborhood(id: "williamsburg", cityId: "nyc", name: "Williamsburg", isActive: true),
                    SimpleNeighborhood(id: "dumbo", cityId: "nyc", name: "DUMBO", isActive: true),
                    SimpleNeighborhood(id: "brooklyn_heights", cityId: "nyc", name: "Brooklyn Heights", isActive: true),
                    SimpleNeighborhood(id: "cobble_hill", cityId: "nyc", name: "Cobble Hill", isActive: true),
                    SimpleNeighborhood(id: "park_slope", cityId: "nyc", name: "Park Slope", isActive: true),
                    SimpleNeighborhood(id: "fort_greene", cityId: "nyc", name: "Fort Greene", isActive: true),
                    SimpleNeighborhood(id: "greenpoint", cityId: "nyc", name: "Greenpoint", isActive: true),
                    SimpleNeighborhood(id: "bushwick", cityId: "nyc", name: "Bushwick", isActive: true),
                    SimpleNeighborhood(id: "prospect_heights", cityId: "nyc", name: "Prospect Heights", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Other Boroughs",
                neighborhoods: [
                    SimpleNeighborhood(id: "astoria", cityId: "nyc", name: "Astoria", isActive: true),
                    SimpleNeighborhood(id: "long_island_city", cityId: "nyc", name: "Long Island City", isActive: true),
                    SimpleNeighborhood(id: "jersey_city", cityId: "nyc", name: "Jersey City", isActive: true),
                    SimpleNeighborhood(id: "hoboken", cityId: "nyc", name: "Hoboken", isActive: true)
                ]
            )
        ]

        // Load saved selections
        // TODO: Load from UserService
    }

    func clearAll() {
        selectedNeighborhoods.removeAll()
    }

    func save() async {
        // TODO: Save to UserService
    }
}

// MARK: - Preview
#Preview {
    EditNeighborhoodsView()
}
