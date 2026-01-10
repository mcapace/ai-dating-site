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
                        .foregroundColor(.julWarmGray)

                    Spacer()

                    if viewModel.selectedNeighborhoods.count > 0 {
                        Button("Clear all") {
                            viewModel.clearAll()
                        }
                        .font(.julBodySmall)
                        .foregroundColor(.julTerracotta)
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.sm)
                .background(Color.julCream)

                Divider()

                ScrollView {
                    VStack(spacing: JulesSpacing.lg) {
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
                    .padding(.horizontal, JulesSpacing.screen)
                    .padding(.vertical, JulesSpacing.md)
                }
                .background(Color.julCream)
            }
            .navigationTitle("Where I Want to Date")
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
        VStack(alignment: .leading, spacing: JulesSpacing.sm) {
            Text("City")
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

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
                        .foregroundColor(selectedCity != nil ? .julWarmBlack : .julWarmGray)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.julWarmGray)
                }
                .padding(JulesSpacing.md)
                .background(Color.julCard)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
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
        VStack(alignment: .leading, spacing: JulesSpacing.sm) {
            // Group Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(group.name)
                        .font(.julTitle3)
                        .foregroundColor(.julWarmBlack)

                    if selectedCount > 0 {
                        Text("(\(selectedCount))")
                            .font(.julCaption)
                            .foregroundColor(.julTerracotta)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.julWarmGray)
                }
            }

            // Neighborhoods
            if isExpanded {
                FlowLayout(spacing: JulesSpacing.xs) {
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
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
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
                .foregroundColor(isSelected ? .white : .julWarmBlack)
                .padding(.horizontal, JulesSpacing.md)
                .padding(.vertical, JulesSpacing.sm)
                .background(isSelected ? Color.julWarmBlack : Color.julInputBackground)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: JulesSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.julTerracotta)

            Text(text)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)
                .lineSpacing(3)
        }
        .padding(JulesSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.julTerracotta.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
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
        // Note: Using approximate coordinates for NYC neighborhoods
        neighborhoodGroups = [
            NeighborhoodGroup(
                name: "Manhattan - Downtown",
                neighborhoods: [
                    Neighborhood(id: "tribeca", cityId: "nyc", name: "Tribeca", displayName: "Tribeca", latitude: 40.7163, longitude: -74.0086),
                    Neighborhood(id: "soho", cityId: "nyc", name: "SoHo", displayName: "SoHo", latitude: 40.7231, longitude: -74.0026),
                    Neighborhood(id: "west_village", cityId: "nyc", name: "West Village", displayName: "West Village", latitude: 40.7358, longitude: -74.0035),
                    Neighborhood(id: "east_village", cityId: "nyc", name: "East Village", displayName: "East Village", latitude: 40.7265, longitude: -73.9815),
                    Neighborhood(id: "lower_east_side", cityId: "nyc", name: "Lower East Side", displayName: "Lower East Side", latitude: 40.7150, longitude: -73.9843),
                    Neighborhood(id: "financial_district", cityId: "nyc", name: "Financial District", displayName: "Financial District", latitude: 40.7074, longitude: -74.0113),
                    Neighborhood(id: "chelsea", cityId: "nyc", name: "Chelsea", displayName: "Chelsea", latitude: 40.7465, longitude: -74.0014),
                    Neighborhood(id: "greenwich_village", cityId: "nyc", name: "Greenwich Village", displayName: "Greenwich Village", latitude: 40.7336, longitude: -74.0027)
                ]
            ),
            NeighborhoodGroup(
                name: "Manhattan - Midtown",
                neighborhoods: [
                    Neighborhood(id: "midtown_east", cityId: "nyc", name: "Midtown East", displayName: "Midtown East", latitude: 40.7549, longitude: -73.9840),
                    Neighborhood(id: "midtown_west", cityId: "nyc", name: "Midtown West", displayName: "Midtown West", latitude: 40.7549, longitude: -73.9840),
                    Neighborhood(id: "hells_kitchen", cityId: "nyc", name: "Hell's Kitchen", displayName: "Hell's Kitchen", latitude: 40.7638, longitude: -73.9918),
                    Neighborhood(id: "gramercy", cityId: "nyc", name: "Gramercy", displayName: "Gramercy", latitude: 40.7368, longitude: -73.9849),
                    Neighborhood(id: "flatiron", cityId: "nyc", name: "Flatiron", displayName: "Flatiron", latitude: 40.7411, longitude: -73.9897),
                    Neighborhood(id: "murray_hill", cityId: "nyc", name: "Murray Hill", displayName: "Murray Hill", latitude: 40.7479, longitude: -73.9757)
                ]
            ),
            NeighborhoodGroup(
                name: "Manhattan - Uptown",
                neighborhoods: [
                    Neighborhood(id: "upper_east_side", cityId: "nyc", name: "Upper East Side", displayName: "Upper East Side", latitude: 40.7736, longitude: -73.9566),
                    Neighborhood(id: "upper_west_side", cityId: "nyc", name: "Upper West Side", displayName: "Upper West Side", latitude: 40.7870, longitude: -73.9754),
                    Neighborhood(id: "harlem", cityId: "nyc", name: "Harlem", displayName: "Harlem", latitude: 40.8079, longitude: -73.9454),
                    Neighborhood(id: "morningside_heights", cityId: "nyc", name: "Morningside Heights", displayName: "Morningside Heights", latitude: 40.8080, longitude: -73.9620)
                ]
            ),
            NeighborhoodGroup(
                name: "Brooklyn",
                neighborhoods: [
                    Neighborhood(id: "williamsburg", cityId: "nyc", name: "Williamsburg", displayName: "Williamsburg", latitude: 40.7081, longitude: -73.9571),
                    Neighborhood(id: "dumbo", cityId: "nyc", name: "DUMBO", displayName: "DUMBO", latitude: 40.7033, longitude: -73.9881),
                    Neighborhood(id: "brooklyn_heights", cityId: "nyc", name: "Brooklyn Heights", displayName: "Brooklyn Heights", latitude: 40.6962, longitude: -73.9973),
                    Neighborhood(id: "cobble_hill", cityId: "nyc", name: "Cobble Hill", displayName: "Cobble Hill", latitude: 40.6865, longitude: -73.9962),
                    Neighborhood(id: "park_slope", cityId: "nyc", name: "Park Slope", displayName: "Park Slope", latitude: 40.6712, longitude: -73.9776),
                    Neighborhood(id: "fort_greene", cityId: "nyc", name: "Fort Greene", displayName: "Fort Greene", latitude: 40.6893, longitude: -73.9749),
                    Neighborhood(id: "greenpoint", cityId: "nyc", name: "Greenpoint", displayName: "Greenpoint", latitude: 40.7295, longitude: -73.9545),
                    Neighborhood(id: "bushwick", cityId: "nyc", name: "Bushwick", displayName: "Bushwick", latitude: 40.6943, longitude: -73.9212),
                    Neighborhood(id: "prospect_heights", cityId: "nyc", name: "Prospect Heights", displayName: "Prospect Heights", latitude: 40.6776, longitude: -73.9690)
                ]
            ),
            NeighborhoodGroup(
                name: "Other Boroughs",
                neighborhoods: [
                    Neighborhood(id: "astoria", cityId: "nyc", name: "Astoria", displayName: "Astoria", latitude: 40.7644, longitude: -73.9235),
                    Neighborhood(id: "long_island_city", cityId: "nyc", name: "Long Island City", displayName: "Long Island City", latitude: 40.7448, longitude: -73.9485),
                    Neighborhood(id: "jersey_city", cityId: "nyc", name: "Jersey City", displayName: "Jersey City", latitude: 40.7178, longitude: -74.0431),
                    Neighborhood(id: "hoboken", cityId: "nyc", name: "Hoboken", displayName: "Hoboken", latitude: 40.7439, longitude: -74.0324)
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
