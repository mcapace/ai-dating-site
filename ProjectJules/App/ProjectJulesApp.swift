//
//  ProjectJulesApp.swift
//  ProjectJules
//
//  Your AI Matchmaker
//

import SwiftUI

@main
struct ProjectJulesApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authService = AuthService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(authService)
                .preferredColorScheme(appState.colorScheme)
        }
    }
}

// MARK: - Root View
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            switch appState.currentFlow {
            case .splash:
                SplashView(onComplete: {
                    // If still on splash after animation, trigger auth check/transition
                    if appState.currentFlow == .splash {
                        checkAuthState()
                    }
                })
                    .transition(.opacity)

            case .onboarding:
                OnboardingFlowView()
                    .transition(.opacity)

            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentFlow)
        .onAppear {
            checkAuthState()
        }
    }

    private func checkAuthState() {
        Task {
            await authService.checkSession()

            await MainActor.run {
                withAnimation {
                    if authService.isAuthenticated {
                        if authService.currentUser?.hasCompletedOnboarding == true {
                            appState.currentFlow = .main
                        } else {
                            appState.currentFlow = .onboarding
                        }
                    } else {
                        appState.currentFlow = .onboarding
                    }
                }
            }
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var currentFlow: AppFlow = .splash
    @Published var colorScheme: ColorScheme? = nil

    enum AppFlow {
        case splash
        case onboarding
        case main
    }
}
