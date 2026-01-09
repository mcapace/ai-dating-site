//
//  NeighborhoodsView.swift
//  ProjectJules
//
//  Onboarding: Select date neighborhoods
//

import SwiftUI

struct NeighborhoodsView: View {
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
                VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                    // Title
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("Where should we plan your dates?")
                            .font(.julTitle1)
                            .foregroundColor(.julWarmBlack)

                        Text("We'll do our best to choose venues that are convenient for both of you.")
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }

                    // Neighborhood List
                    VStack(spacing: 0) {
                        ForEach(viewModel.availableNeighborhoods) { neighborhood in
                            NeighborhoodRow(
                                name: neighborhood.displayName,
                                isSelected: viewModel.selectedNeighborhoods.contains(neighborhood.id)
                            ) {
                                if viewModel.selectedNeighborhoods.contains(neighborhood.id) {
                                    viewModel.selectedNeighborhoods.remove(neighborhood.id)
                                } else {
                                    viewModel.selectedNeighborhoods.insert(neighborhood.id)
                                }
                            }

                            if neighborhood.id != viewModel.availableNeighborhoods.last?.id {
                                Divider()
                                    .background(Color.julDivider)
                            }
                        }
                    }
                    .background(Color.julCard)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.top, JulesSpacing.lg)
            }

            // Continue Button
            JulesButton(
                title: "Continue",
                style: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.selectedNeighborhoods.isEmpty
            ) {
                Task {
                    await viewModel.saveNeighborhoods()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
        }
        .task {
            await viewModel.loadNeighborhoods()
        }
    }
}

// MARK: - Neighborhood Row
struct NeighborhoodRow: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(name)
                    .font(.julBody)
                    .foregroundColor(.julWarmBlack)

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.julWarmBlack : Color.julWarmGray, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.julWarmBlack)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .padding(.horizontal, JulesSpacing.md)
            .padding(.vertical, JulesSpacing.sm + 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    let vm = OnboardingViewModel()
    vm.availableNeighborhoods = [
        Neighborhood(id: "1", cityId: "nyc", name: "downtown", displayName: "Downtown / West Village", latitude: 40.73, longitude: -74.00),
        Neighborhood(id: "2", cityId: "nyc", name: "east_village", displayName: "East Village / LES", latitude: 40.72, longitude: -73.98),
        Neighborhood(id: "3", cityId: "nyc", name: "midtown", displayName: "Midtown", latitude: 40.75, longitude: -73.98),
        Neighborhood(id: "4", cityId: "nyc", name: "williamsburg", displayName: "Williamsburg", latitude: 40.70, longitude: -73.95),
    ]
    return NeighborhoodsView(viewModel: vm)
        .background(Color.julCream)
}
