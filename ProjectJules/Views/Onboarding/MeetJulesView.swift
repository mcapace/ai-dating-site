//
//  MeetJulesView.swift
//  ProjectJules
//
//  Onboarding: Meet Jules Transition
//

import SwiftUI

struct MeetJulesView: View {
    let onContinue: () -> Void

    @State private var isAnimated = false
    @State private var showText = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Jules Avatar with animation
            VStack(spacing: Spacing.xl) {
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color.julTerracotta.opacity(0.1 - Double(index) * 0.03), lineWidth: 2)
                            .frame(width: 140 + CGFloat(index * 40), height: 140 + CGFloat(index * 40))
                            .scaleEffect(isAnimated ? 1.1 : 0.9)
                            .opacity(isAnimated ? 0.6 : 0.2)
                            .animation(
                                .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                value: isAnimated
                            )
                    }

                    // Jules Avatar - simplified
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
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("J")
                                .font(.system(size: 56, weight: .semibold, design: .serif))
                                .foregroundColor(.julTerracotta)
                        )
                        .scaleEffect(isAnimated ? 1 : 0.5)
                        .opacity(isAnimated ? 1 : 0)
                }

                // Text
                VStack(spacing: Spacing.sm) {
                    Text("Alright, basics covered.")
                        .font(.julHeadline3())
                        .foregroundColor(.julTextPrimary)

                    Text("Now let's actually get\nto know each other.")
                        .font(.julBodyLarge())
                        .foregroundColor(.julTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 20)
            }

            Spacer()

            // Continue Button
            JulesButton(title: "Meet Jules", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
            .opacity(showText ? 1 : 0)
        }
        .background(Color.julCream)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimated = true
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                showText = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MeetJulesView(onContinue: {})
}
