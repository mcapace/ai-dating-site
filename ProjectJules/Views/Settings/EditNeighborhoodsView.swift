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
                        .font(.julBody)
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
    let cities: [City]
    @Binding var selectedCity: City?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("City")
                .font(.julLabelSmall())
                .foregroundColor(.julTextSecondary)

            Menu {
                ForEach(cities) { city in
                    Button(city.name) {
                        selectedCity = city
                    }
                }
            } label: {
                HStack {
                    Text(selectedCity?.name ?? "Select city")
                        .font(.julBody)
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
    let neighborhood: Neighborhood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(neighborhood.name)
                .font(.julBody)
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

// MARK: - Neighborhood Group Model
struct NeighborhoodGroup {
    let name: String
    let neighborhoods: [Neighborhood]
}

// MARK: - View Model
@MainActor
class EditNeighborhoodsViewModel: ObservableObject {
    @Published var availableCities: [City] = []
    @Published var selectedCity: City?
    @Published var neighborhoodGroups: [NeighborhoodGroup] = []
    @Published var selectedNeighborhoods: Set<String> = []

    init() {
        loadData()
    }

    private func loadData() {
        // NYC neighborhoods grouped by area
        neighborhoodGroups = [
            NeighborhoodGroup(
                name: "Manhattan - Downtown",
                neighborhoods: [
                    Neighborhood(id: "tribeca", cityId: "nyc", name: "Tribeca", isActive: true),
                    Neighborhood(id: "soho", cityId: "nyc", name: "SoHo", isActive: true),
                    Neighborhood(id: "west_village", cityId: "nyc", name: "West Village", isActive: true),
                    Neighborhood(id: "east_village", cityId: "nyc", name: "East Village", isActive: true),
                    Neighborhood(id: "lower_east_side", cityId: "nyc", name: "Lower East Side", isActive: true),
                    Neighborhood(id: "financial_district", cityId: "nyc", name: "Financial District", isActive: true),
                    Neighborhood(id: "chelsea", cityId: "nyc", name: "Chelsea", isActive: true),
                    Neighborhood(id: "greenwich_village", cityId: "nyc", name: "Greenwich Village", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Manhattan - Midtown",
                neighborhoods: [
                    Neighborhood(id: "midtown_east", cityId: "nyc", name: "Midtown East", isActive: true),
                    Neighborhood(id: "midtown_west", cityId: "nyc", name: "Midtown West", isActive: true),
                    Neighborhood(id: "hells_kitchen", cityId: "nyc", name: "Hell's Kitchen", isActive: true),
                    Neighborhood(id: "gramercy", cityId: "nyc", name: "Gramercy", isActive: true),
                    Neighborhood(id: "flatiron", cityId: "nyc", name: "Flatiron", isActive: true),
                    Neighborhood(id: "murray_hill", cityId: "nyc", name: "Murray Hill", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Manhattan - Uptown",
                neighborhoods: [
                    Neighborhood(id: "upper_east_side", cityId: "nyc", name: "Upper East Side", isActive: true),
                    Neighborhood(id: "upper_west_side", cityId: "nyc", name: "Upper West Side", isActive: true),
                    Neighborhood(id: "harlem", cityId: "nyc", name: "Harlem", isActive: true),
                    Neighborhood(id: "morningside_heights", cityId: "nyc", name: "Morningside Heights", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Brooklyn",
                neighborhoods: [
                    Neighborhood(id: "williamsburg", cityId: "nyc", name: "Williamsburg", isActive: true),
                    Neighborhood(id: "dumbo", cityId: "nyc", name: "DUMBO", isActive: true),
                    Neighborhood(id: "brooklyn_heights", cityId: "nyc", name: "Brooklyn Heights", isActive: true),
                    Neighborhood(id: "cobble_hill", cityId: "nyc", name: "Cobble Hill", isActive: true),
                    Neighborhood(id: "park_slope", cityId: "nyc", name: "Park Slope", isActive: true),
                    Neighborhood(id: "fort_greene", cityId: "nyc", name: "Fort Greene", isActive: true),
                    Neighborhood(id: "greenpoint", cityId: "nyc", name: "Greenpoint", isActive: true),
                    Neighborhood(id: "bushwick", cityId: "nyc", name: "Bushwick", isActive: true),
                    Neighborhood(id: "prospect_heights", cityId: "nyc", name: "Prospect Heights", isActive: true)
                ]
            ),
            NeighborhoodGroup(
                name: "Other Boroughs",
                neighborhoods: [
                    Neighborhood(id: "astoria", cityId: "nyc", name: "Astoria", isActive: true),
                    Neighborhood(id: "long_island_city", cityId: "nyc", name: "Long Island City", isActive: true),
                    Neighborhood(id: "jersey_city", cityId: "nyc", name: "Jersey City", isActive: true),
                    Neighborhood(id: "hoboken", cityId: "nyc", name: "Hoboken", isActive: true)
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
