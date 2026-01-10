//
//  MainTabView.swift
//  ProjectJules
//
//  Main App Tab Navigation
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home
        case intros
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                    Text("Home")
                }

            IntrosListView()
                .tag(Tab.intros)
                .tabItem {
                    Image(systemName: selectedTab == .intros ? "heart.fill" : "heart")
                    Text("Intros")
                }

            ProfileView()
                .tag(Tab.profile)
                .tabItem {
                    Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                    Text("Profile")
                }
        }
        .tint(.julTerracotta)
    }
}

// MARK: - Home View (Jules Chat)
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    JulesAvatar(size: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Jules")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)
                    }

                    Spacer()

                    JulesIconButton(icon: "gearshape", size: 36, backgroundColor: .julInputBackground, iconColor: .julWarmGray) {
                        // Settings
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.sm)

                Divider()
                    .background(Color.julDivider)

                // Chat content
                ScrollView {
                    LazyVStack(spacing: JulesSpacing.md) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }

                        // If there's a pending match to show
                        if let match = viewModel.currentMatch {
                            MatchCard(
                                match: match,
                                onAccept: { viewModel.acceptMatch() },
                                onDecline: { viewModel.declineMatch() },
                                onSeeProfile: { viewModel.showFullProfile() }
                            )
                            .padding(.top, JulesSpacing.sm)
                        }
                    }
                    .padding(.horizontal, JulesSpacing.screen)
                    .padding(.vertical, JulesSpacing.md)
                }

                // Input
                ChatInputBar(
                    text: $viewModel.inputText,
                    showVoiceButton: false,
                    onSend: viewModel.sendMessage
                )
            }
            .background(Color.julCream)
        }
    }
}

// MARK: - Home View Model
@MainActor
class HomeViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMatch: MatchPresentation?
    @Published var inputText = ""

    init() {
        // Load initial welcome message
        messages = [
            ChatMessage(
                id: UUID().uuidString,
                content: "Hey! I've been looking through some people and I think I found someone interesting. Give me a sec to tell you about her...",
                isFromJules: true,
                timestamp: Date()
            )
        ]
    }

    func sendMessage() {
        guard !inputText.isEmpty else { return }

        let message = ChatMessage(
            id: UUID().uuidString,
            content: inputText,
            isFromJules: false,
            timestamp: Date()
        )
        messages.append(message)
        inputText = ""

        // TODO: Send to Jules service and get response
    }

    func acceptMatch() {
        // TODO: Accept match flow
    }

    func declineMatch() {
        // TODO: Decline match flow
    }

    func showFullProfile() {
        // TODO: Show full profile
    }
}

// MARK: - Intros List View
struct IntrosListView: View {
    @StateObject private var viewModel = IntrosViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: JulesSpacing.sm) {
                    if viewModel.intros.isEmpty {
                        // Empty state
                        VStack(spacing: JulesSpacing.lg) {
                            Spacer()
                                .frame(height: JulesSpacing.hero)

                            JulesAvatar(size: 80)

                            VStack(spacing: JulesSpacing.xs) {
                                Text("No intros yet")
                                    .font(.julTitle2)
                                    .foregroundColor(.julWarmBlack)

                                Text("When you and someone both say yes,\nyou'll see your intro here.")
                                    .font(.julBody)
                                    .foregroundColor(.julWarmGray)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    } else {
                        ForEach(viewModel.intros) { intro in
                            IntroListCard(intro: intro) {
                                viewModel.selectIntro(intro)
                            }
                        }
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("My Intros")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Intros View Model
@MainActor
class IntrosViewModel: ObservableObject {
    @Published var intros: [IntroListItem] = []

    func selectIntro(_ intro: IntroListItem) {
        // Navigate to intro detail
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showEditProfile = false
    @State private var showEditPreferences = false
    @State private var showSubscription = false
    @State private var showEditNeighborhoods = false
    @State private var showSafetyTips = false
    @State private var showContactSupport = false
    @State private var showTerms = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: JulesSpacing.lg) {
                    // Profile Header
                    VStack(spacing: JulesSpacing.md) {
                        // Profile photo
                        if let photoURL = authService.currentProfile?.primaryPhotoURL {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle()
                                    .fill(Color.julInputBackground)
                                    .overlay(ProgressView())
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.julInputBackground)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.julWarmGray)
                                )
                        }

                        if let profile = authService.currentProfile {
                            Text("\(profile.firstName), \(profile.age)")
                                .font(.julTitle2)
                                .foregroundColor(.julWarmBlack)
                        }

                        // Subscription badge
                        if authService.currentUser?.subscriptionTier == .premium {
                            HStack(spacing: 4) {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 12))
                                Text("Premium")
                                    .font(.julCaption)
                            }
                            .foregroundColor(.julTerracotta)
                            .padding(.horizontal, JulesSpacing.sm)
                            .padding(.vertical, 4)
                            .background(Color.julTerracotta.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.top, JulesSpacing.lg)

                    // Menu Items - Profile Settings
                    VStack(spacing: 0) {
                        ProfileMenuItem(icon: "person", title: "My info") {
                            showEditProfile = true
                        }
                        ProfileMenuItem(icon: "slider.horizontal.3", title: "Who I'm looking for") {
                            showEditPreferences = true
                        }
                        ProfileMenuItem(icon: "ticket", title: "My subscription") {
                            showSubscription = true
                        }
                        ProfileMenuItem(icon: "mappin", title: "Where I want to date") {
                            showEditNeighborhoods = true
                        }
                    }
                    .background(Color.julCard)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))

                    // Menu Items - Support
                    VStack(spacing: 0) {
                        ProfileMenuItem(icon: "shield", title: "Safety tips") {
                            showSafetyTips = true
                        }
                        ProfileMenuItem(icon: "bubble.left", title: "Contact support") {
                            showContactSupport = true
                        }
                        ProfileMenuItem(icon: "doc.text", title: "Terms and privacy") {
                            showTerms = true
                        }
                    }
                    .background(Color.julCard)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))

                    // Sign Out
                    JulesButton(title: "Sign Out", style: .secondary) {
                        Task {
                            try? await authService.signOut()
                        }
                    }

                    JulesButton(title: "Delete Account", style: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.bottom, JulesSpacing.xl)
            }
            .background(Color.julCream)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showEditPreferences) {
                EditPreferencesView()
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $showEditNeighborhoods) {
                EditNeighborhoodsView()
            }
            .sheet(isPresented: $showSafetyTips) {
                SafetyTipsView()
            }
            .sheet(isPresented: $showContactSupport) {
                ContactSupportView()
            }
            .sheet(isPresented: $showTerms) {
                TermsPrivacyView()
            }
            .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task { try? await authService.deleteAccount() }
                }
            } message: {
                Text("This will permanently delete your account and all your data. This cannot be undone.")
            }
        }
    }
}

// MARK: - Profile Menu Item
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: JulesSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.julWarmGray)
                    .frame(width: 24)

                Text(title)
                    .font(.julBody)
                    .foregroundColor(.julWarmBlack)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.julWarmGray)
            }
            .padding(.horizontal, JulesSpacing.md)
            .padding(.vertical, JulesSpacing.sm + 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AuthService.shared)
}

