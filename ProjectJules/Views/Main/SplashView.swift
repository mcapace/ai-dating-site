//
//  SplashView.swift
//  ProjectJules
//
//  Animated Splash Screen
//

import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var showShimmer = false

    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background
            Color.julCream
                .ignoresSafeArea()

            VStack(spacing: JulesSpacing.lg) {
                // Animated Logo Container
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.julTerracotta.opacity(0.3),
                                    Color.julSage.opacity(0.2),
                                    Color.julTerracotta.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Logo background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F7E6DC"), Color(hex: "E6D5C8")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.julTerracotta.opacity(0.2), radius: 20, x: 0, y: 10)

                    // Jules "J" mark
                    Text("J")
                        .font(.system(size: 56, weight: .semibold, design: .serif))
                        .foregroundColor(.julTerracotta)

                    // Shimmer overlay (placeholder for Lottie)
                    if showShimmer {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.4),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .mask(Circle())
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App Name
                VStack(spacing: JulesSpacing.xs) {
                    Text("Jules")
                        .font(.system(size: 32, weight: .semibold, design: .serif))
                        .foregroundColor(.julWarmBlack)

                    Text("Your AI Matchmaker")
                        .font(.julBody)
                        .foregroundColor(.julWarmGray)
                }
                .opacity(taglineOpacity)
            }
        }
        .onAppear {
            animateSplash()
        }
    }

    private func animateSplash() {
        // Logo entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Ring pulse
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            ringScale = 1.0
            ringOpacity = 1.0
        }

        // Tagline fade in
        withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
            taglineOpacity = 1.0
        }

        // Shimmer effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) {
                showShimmer = true
            }
        }

        // Complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onComplete()
        }
    }
}

// MARK: - Animated Logo (Reusable)
struct AnimatedJulesLogo: View {
    var size: CGFloat = 80
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Pulse ring
            Circle()
                .stroke(Color.julTerracotta.opacity(0.2), lineWidth: 2)
                .frame(width: size + 20, height: size + 20)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0 : 0.5)

            // Logo background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "F7E6DC"), Color(hex: "E6D5C8")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // J mark
            Text("J")
                .font(.system(size: size * 0.45, weight: .semibold, design: .serif))
                .foregroundColor(.julTerracotta)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SplashView(onComplete: {})
}
