//
//  ProjectJulesApp.swift
//  ProjectJules
//
//  Main app entry point with routing
//

import SwiftUI

@main
struct ProjectJulesApp: App {
    @StateObject private var authService = AuthService()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    ContentView()
                        .environmentObject(authService)
                }
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                OnboardingFlowView()
            }
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.julBackground
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // Logo placeholder
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Color.julTerracotta)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text("J")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text("Jules")
                    .font(.julHeadline1())
                    .foregroundColor(.julTextPrimary)
            }
        }
    }
}

