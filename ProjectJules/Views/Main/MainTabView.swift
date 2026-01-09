//
//  MainTabView.swift
//  ProjectJules
//
//  Main tab navigation
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            IntrosView()
                .tabItem {
                    Label("Intros", systemImage: "heart.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.julTerracotta)
    }
}

struct HomeView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Text("Discover Matches")
                        .font(.julHeadline2())
                        .foregroundColor(.julTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.md)
                    
                    // Match cards placeholder
                    ForEach(0..<3) { _ in
                        MatchCard(match: Match.preview) {
                            // Navigate to match detail
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                }
                .padding(.vertical, Spacing.md)
            }
            .navigationTitle("Jules")
            .background(Color.julBackground)
        }
    }
}

struct IntrosView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    Text("Your Introductions")
                        .font(.julHeadline2())
                        .foregroundColor(.julTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Spacing.md)
                    
                    // Intro cards placeholder
                    ForEach(0..<2) { _ in
                        IntroCard(intro: Intro.preview) {
                            // Navigate to intro detail
                        }
                        .padding(.horizontal, Spacing.md)
                    }
                }
                .padding(.vertical, Spacing.md)
            }
            .navigationTitle("Intros")
            .background(Color.julBackground)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Profile header placeholder
                    VStack(spacing: Spacing.md) {
                        Circle()
                            .fill(Color.julCream)
                            .frame(width: 100, height: 100)
                        
                        Text("Your Name")
                            .font(.julHeadline3())
                            .foregroundColor(.julTextPrimary)
                    }
                    .padding(.top, Spacing.xl)
                    
                    // Settings options
                    VStack(spacing: Spacing.sm) {
                        NavigationLink(destination: SettingsView()) {
                            HStack {
                                Text("Settings")
                                    .font(.julBody())
                                    .foregroundColor(.julTextPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.julTextSecondary)
                            }
                            .padding(Spacing.md)
                            .background(Color.julCardBackground)
                            .cornerRadius(Radius.md)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
            }
            .navigationTitle("Profile")
            .background(Color.julBackground)
        }
    }
}

