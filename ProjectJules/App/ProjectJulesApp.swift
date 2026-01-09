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
                    SplashView(onComplete: {
                        showSplash = false
                    })
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


