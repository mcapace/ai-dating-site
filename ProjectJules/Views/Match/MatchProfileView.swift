//
//  MatchProfileView.swift
//  ProjectJules
//
//  Full Match Profile View
//

import SwiftUI

struct MatchProfileView: View {
    let matchId: String
    @StateObject private var viewModel: MatchProfileViewModel
    @Environment(\.dismiss) private var dismiss

    init(matchId: String) {
        self.matchId = matchId
        _viewModel = StateObject(wrappedValue: MatchProfileViewModel(matchId: matchId))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Photo Gallery
                    PhotoGallery(
                        photos: viewModel.photos,
                        currentIndex: $viewModel.currentPhotoIndex
                    )

                    // Profile Content
                    VStack(spacing: Spacing.lg) {
                        // Name & Basic Info
                        ProfileHeader(
                            name: viewModel.profile?.firstName ?? "",
                            age: viewModel.profile?.age ?? 0,
                            location: "New York City",
                            occupation: viewModel.profile?.occupation ?? ""
                        )

                        // Tags
                        if !viewModel.tags.isEmpty {
                            ProfileTags(tags: viewModel.tags)
                        }

                        // Jules' Take (AI-generated compatibility summary)
                        if let julesTake = viewModel.julesTake {
                            JulesTakeSection(content: julesTake)
                        }

                        // About Section
                        if let bio = viewModel.profile?.bio, !bio.isEmpty {
                            AboutSection(bio: bio)
                        }

                        // Details Grid
                        ProfileDetailsGrid(profile: viewModel.profile)

                        // Looking For
                        if let lookingFor = viewModel.lookingFor {
                            LookingForSection(text: lookingFor)
                        }

                        // Dealbreakers (shown tastefully)
                        if !viewModel.dealbreakers.isEmpty {
                            DealbreakerSection(dealbreakers: viewModel.dealbreakers)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, 100) // Space for action buttons
                }
            }
            .background(Color.julCream)
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .bottom) {
                // Action buttons (only if from match flow)
                if viewModel.showActions {
                    ProfileActionBar(
                        onDecline: { viewModel.declineMatch() },
                        onAccept: { viewModel.acceptMatch() }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Photo Gallery
struct PhotoGallery: View {
    let photos: [String]
    @Binding var currentIndex: Int

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentIndex) {
                ForEach(Array(photos.enumerated()), id: \.offset) { index, photoURL in
                    AsyncImage(url: URL(string: photoURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(Color.julCream)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.julTextSecondary)
                                )
                        case .empty:
                            Rectangle()
                                .fill(Color.julCream)
                                .overlay(ProgressView())
                        @unknown default:
                            Rectangle()
                                .fill(Color.julCream)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 450)

            // Photo indicators
            HStack(spacing: 4) {
                ForEach(0..<photos.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                        .frame(width: index == currentIndex ? 24 : 8, height: 4)
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
            .padding(.bottom, Spacing.md)
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    let name: String
    let age: Int
    let location: String
    let occupation: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("\(name), \(age)")
                .font(.julHeadline1())
                .foregroundColor(.julTextPrimary)

            HStack(spacing: Spacing.sm) {
                Label(location, systemImage: "mappin")
                Text("·")
                Text(occupation)
            }
            .font(.julBody())
            .foregroundColor(.julTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Profile Tags
struct ProfileTags: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: Spacing.xs) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.julBodySmall())
                    .foregroundColor(.julTextPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.julCardBackground)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Jules' Take Section
struct JulesTakeSection: View {
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.97, green: 0.90, blue: 0.86),
                                Color(red: 0.90, green: 0.84, blue: 0.78)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text("J")
                            .font(.system(size: 14, weight: .semibold, design: .serif))
                            .foregroundColor(.julTerracotta)
                    )

                Text("Jules' Take")
                    .font(.julHeadline3())
                    .foregroundColor(.julTextPrimary)
            }

            Text(content)
                .font(.julBody())
                .foregroundColor(.julTextPrimary)
                .lineSpacing(4)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.94, blue: 0.90),
                    Color(red: 0.96, green: 0.90, blue: 0.84)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

// MARK: - About Section
struct AboutSection: View {
    let bio: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("About")
                .font(.julHeadline3())
                .foregroundColor(.julTextPrimary)

            Text(bio)
                .font(.julBody())
                .foregroundColor(.julTextPrimary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Profile Details Grid
struct ProfileDetailsGrid: View {
    let profile: UserProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Details")
                .font(.julHeadline3())
                .foregroundColor(.julTextPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: Spacing.sm
            ) {
                if let height = profile?.heightInches {
                    DetailItem(icon: "ruler", label: "Height", value: formatHeight(height))
                }

                if let education = profile?.education {
                    DetailItem(icon: "graduationcap", label: "Education", value: education)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatHeight(_ inches: Int) -> String {
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }
}

struct DetailItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.julTerracotta)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.julLabelSmall())
                    .foregroundColor(.julTextSecondary)

                Text(value)
                    .font(.julBody())
                    .foregroundColor(.julTextPrimary)
            }

            Spacer()
        }
        .padding(Spacing.sm)
        .background(Color.julCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Radius.sm))
    }
}

// MARK: - Looking For Section
struct LookingForSection: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(.julSage)

                Text("Looking for")
                    .font(.julHeadline3())
                    .foregroundColor(.julTextPrimary)
            }

            Text(text)
                .font(.julBody())
                .foregroundColor(.julTextPrimary)
                .lineSpacing(4)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.julSage.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Radius.md))
    }
}

// MARK: - Dealbreaker Section
struct DealbreakerSection: View {
    let dealbreakers: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Important to them")
                .font(.julLabelSmall())
                .foregroundColor(.julTextSecondary)

            FlowLayout(spacing: Spacing.xs) {
                ForEach(dealbreakers, id: \.self) { item in
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                        Text(item)
                            .font(.julLabelSmall())
                    }
                    .foregroundColor(.julTextSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.julBorder)
                    .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Profile Action Bar
struct ProfileActionBar: View {
    let onDecline: () -> Void
    let onAccept: () -> Void

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Decline
            Button(action: onDecline) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.julTextSecondary)
                    .frame(width: 64, height: 64)
                    .background(Color.julCardBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            }

            // Accept
            Button(action: onAccept) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 72, height: 72)
                    .background(
                        LinearGradient(
                            colors: [Color.julTerracotta, Color.julTerracotta.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.julTerracotta.opacity(0.4), radius: 12, x: 0, y: 6)
            }
        }
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.xl)
        .background(
            LinearGradient(
                colors: [Color.julCream.opacity(0), Color.julCream],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - View Model
@MainActor
class MatchProfileViewModel: ObservableObject {
    let matchId: String

    @Published var profile: UserProfile?
    @Published var photos: [String] = []
    @Published var currentPhotoIndex = 0
    @Published var tags: [String] = []
    @Published var julesTake: String?
    @Published var lookingFor: String?
    @Published var dealbreakers: [String] = []
    @Published var showActions = true
    @Published var isLoading = false

    init(matchId: String) {
        self.matchId = matchId
        loadProfile()
    }

    private func loadProfile() {
        // Mock data for preview
        profile = UserProfile(
            id: UUID(),
            userId: UUID(),
            firstName: "Sarah",
            lastName: nil,
            dateOfBirth: Calendar.current.date(byAdding: .year, value: -28, to: Date()),
            bio: "I spend my weekends exploring coffee shops, taking photos of interesting architecture, and pretending I'll finish that book I started three months ago. Looking for someone who appreciates a good playlist and doesn't mind my plant obsession.",
            gender: "Woman",
            occupation: "Product Designer",
            education: "Bachelor's Degree",
            heightInches: 66,
            createdAt: Date(),
            updatedAt: Date()
        )

        photos = [
            "https://picsum.photos/seed/1/400/500",
            "https://picsum.photos/seed/2/400/500",
            "https://picsum.photos/seed/3/400/500"
        ]

        tags = ["5'6\"", "No kids", "Designer", "Yoga", "Coffee addict"]

        julesTake = "You both said dive bars over cocktail bars, and she hates small talk as much as you do. Plus, you're both into architecture and have an unhealthy relationship with your plant collections."

        lookingFor = "Something real that starts slow. I want to actually get to know someone before committing to anything. Bonus points if you can make me laugh."

        dealbreakers = ["Non-smoker", "Active lifestyle", "No kids yet"]
    }

    func acceptMatch() {
        // TODO: Call match service
    }

    func declineMatch() {
        // TODO: Call match service
    }
}

// MARK: - Preview
#Preview {
    MatchProfileView(matchId: "preview-123")
}
