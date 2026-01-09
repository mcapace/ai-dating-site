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

struct EditProfileView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    
    var body: some View {
        Form {
            Section("Basic Info") {
                JulesTextField(title: "First Name", text: $firstName)
                JulesTextField(title: "Last Name", text: $lastName)
                JulesTextField(title: "Bio", text: $bio)
            }
            
            Section {
                JulesButton(title: "Save Changes", style: .primary) {
                    // Save
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}

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

struct SubscriptionView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Subscription")
                .font(.julHeadline2())
                .foregroundColor(.julTextPrimary)
            
            Text("Upgrade to Premium for more features")
                .font(.julBody())
                .foregroundColor(.julTextSecondary)
            
            JulesButton(title: "Upgrade to Premium", style: .primary) {
                // Handle upgrade
            }
        }
        .padding(Spacing.lg)
        .navigationTitle("Subscription")
    }
}

struct SafetyTipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Safety Tips")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                
                Text("Content for safety tips...")
                    .font(.julBody())
                    .foregroundColor(.julTextSecondary)
            }
            .padding(Spacing.lg)
        }
        .navigationTitle("Safety Tips")
    }
}

struct ContactSupportView: View {
    @State private var message: String = ""
    
    var body: some View {
        Form {
            Section("Contact Us") {
                TextEditor(text: $message)
                    .frame(height: 200)
            }
            
            Section {
                JulesButton(title: "Send", style: .primary) {
                    // Send message
                }
            }
        }
        .navigationTitle("Contact Support")
    }
}

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

