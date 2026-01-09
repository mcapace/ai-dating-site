//
//  SettingsView.swift
//  ProjectJules
//
//  Settings and profile management
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showEditProfile = false
    @State private var showPreferences = false
    @State private var showNeighborhoods = false
    @State private var showSubscription = false
    
    var body: some View {
        List {
            Section("Profile") {
                NavigationLink("Edit Profile", destination: EditProfileView())
                NavigationLink("Preferences", destination: PreferencesSettingsView())
                NavigationLink("Neighborhoods", destination: NeighborhoodsSettingsView())
            }
            
            Section("Subscription") {
                NavigationLink("Manage Subscription", destination: SubscriptionView())
            }
            
            Section("Support") {
                NavigationLink("Safety Tips", destination: SafetyTipsView())
                NavigationLink("Contact Support", destination: ContactSupportView())
                NavigationLink("Terms of Service", destination: TermsView())
                NavigationLink("Privacy Policy", destination: PrivacyView())
            }
            
            Section {
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await authService.signOut()
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

// EditProfileView is defined in EditProfileView.swift

struct PreferencesSettingsView: View {
    var body: some View {
        Text("Preferences Settings")
            .navigationTitle("Preferences")
    }
}

struct NeighborhoodsSettingsView: View {
    var body: some View {
        Text("Neighborhoods Settings")
            .navigationTitle("Neighborhoods")
    }
}

// SubscriptionView is defined in SubscriptionView.swift
// SafetyTipsView and ContactSupportView are defined in SupportViews.swift

struct TermsView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service content...")
                .font(.julBody())
                .foregroundColor(.julTextSecondary)
                .padding(Spacing.lg)
        }
        .navigationTitle("Terms of Service")
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy content...")
                .font(.julBody())
                .foregroundColor(.julTextSecondary)
                .padding(Spacing.lg)
        }
        .navigationTitle("Privacy Policy")
    }
}

