//
//  WelcomeView.swift
//  ProjectJules
//
//  Onboarding: Welcome Screen
//

import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var isAnimated = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo / Branding
            VStack(spacing: JulesSpacing.lg) {
                // App Icon / Logo placeholder
                ZStack {
                    Circle()
                        .fill(LinearGradient.julSparkGradient)
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimated ? 1 : 0.8)
                        .opacity(isAnimated ? 1 : 0)

                    Text("J")
                        .font(.system(size: 48, weight: .semibold, design: .serif))
                        .foregroundColor(.julTerracotta)
                        .scaleEffect(isAnimated ? 1 : 0.5)
                        .opacity(isAnimated ? 1 : 0)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAnimated)

                // App Name
                VStack(spacing: JulesSpacing.xs) {
                    Text("Project Jules")
                        .font(.julHero)
                        .foregroundColor(.julWarmBlack)
                        .opacity(isAnimated ? 1 : 0)
                        .offset(y: isAnimated ? 0 : 20)

                    Text("Meet people worth meeting")
                        .font(.julBodyLarge)
                        .foregroundColor(.julWarmGray)
                        .opacity(isAnimated ? 1 : 0)
                        .offset(y: isAnimated ? 0 : 20)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isAnimated)
            }

            Spacer()

            // Value Props
            VStack(spacing: JulesSpacing.lg) {
                ValuePropRow(
                    icon: "sparkles",
                    title: "AI-Powered Matchmaking",
                    subtitle: "Jules learns what you actually want"
                )

                ValuePropRow(
                    icon: "person.2",
                    title: "Real Dates, Not Endless Texting",
                    subtitle: "We get you face-to-face faster"
                )

                ValuePropRow(
                    icon: "heart",
                    title: "Quality Over Quantity",
                    subtitle: "Curated matches, not infinite swiping"
                )
            }
            .padding(.horizontal, JulesSpacing.screen)
            .opacity(isAnimated ? 1 : 0)
            .offset(y: isAnimated ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: isAnimated)

            Spacer()

            // CTA Button
            VStack(spacing: JulesSpacing.md) {
                JulesButton(title: "Get Started", style: .primary) {
                    onContinue()
                }

                JulesTextButton(title: "Already have an account? Sign in", color: .julWarmGray) {
                    onContinue() // Same flow for now
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
            .opacity(isAnimated ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: isAnimated)
        }
        .background(Color.julCream)
        .onAppear {
            isAnimated = true
        }
    }
}

// MARK: - Value Prop Row
struct ValuePropRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: JulesSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.julTerracotta)
                .frame(width: 48, height: 48)
                .background(Color.julTerracotta.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.julTitle3)
                    .foregroundColor(.julWarmBlack)

                Text(subtitle)
                    .font(.julBodySmall)
                    .foregroundColor(.julWarmGray)
            }

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(onContinue: {})
}
