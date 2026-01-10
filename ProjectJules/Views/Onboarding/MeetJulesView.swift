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
            VStack(spacing: JulesSpacing.xl) {
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

                    // Jules Avatar
                    JulesAvatar(size: 120)
                        .scaleEffect(isAnimated ? 1 : 0.5)
                        .opacity(isAnimated ? 1 : 0)
                }

                // Text
                VStack(spacing: JulesSpacing.sm) {
                    Text("Alright, basics covered.")
                        .font(.julTitle2)
                        .foregroundColor(.julWarmBlack)

                    Text("Now let's actually get\nto know each other.")
                        .font(.julBodyLarge)
                        .foregroundColor(.julWarmGray)
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
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
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

// MARK: - Jules Onboarding Chat View
struct JulesOnboardingChatView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    @State private var inputText = ""
    @State private var isTyping = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                JulesAvatar(size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Jules")
                        .font(.julTitle3)
                        .foregroundColor(.julWarmBlack)

                    if isTyping {
                        Text("typing...")
                            .font(.julCaption)
                            .foregroundColor(.julWarmGray)
                    }
                }

                Spacer()

                // Progress indicator
                Text("\(viewModel.currentJulesQuestion + 1)/7")
                    .font(.julCaption)
                    .foregroundColor(.julWarmGray)
                    .padding(.horizontal, JulesSpacing.sm)
                    .padding(.vertical, JulesSpacing.xxs)
                    .background(Color.julInputBackground)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.vertical, JulesSpacing.sm)
            .background(Color.julCream)

            Divider()
                .background(Color.julDivider)

            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: JulesSpacing.md) {
                        ForEach(viewModel.julesMessages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        if isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding(.horizontal, JulesSpacing.screen)
                    .padding(.vertical, JulesSpacing.md)
                }
                .onChange(of: viewModel.julesMessages.count) { _, _ in
                    if let lastMessage = viewModel.julesMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input Area
            VStack(spacing: 0) {
                Divider()
                    .background(Color.julDivider)

                HStack(spacing: JulesSpacing.sm) {
                    TextField("Type your answer...", text: $inputText, axis: .vertical)
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                        .lineLimit(1...5)
                        .padding(.horizontal, JulesSpacing.md)
                        .padding(.vertical, JulesSpacing.sm)
                        .background(Color.julInputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .focused($inputFocused)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(inputText.isEmpty ? Color.julWarmGray : Color.julWarmBlack)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.sm)
                .background(Color.julCream)
            }
        }
        .background(Color.julCream)
        .task {
            await viewModel.startJulesChat()
        }
    }

    private func sendMessage() {
        let message = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }

        inputText = ""
        isTyping = true

        Task {
            await viewModel.sendJulesAnswer(message)

            await MainActor.run {
                isTyping = false

                // Check if onboarding is complete
                if viewModel.currentJulesQuestion >= 7 {
                    // Add completion message
                    let completionMessage = ChatMessage(
                        id: UUID().uuidString,
                        content: "Okay, I feel like I'm starting to get you. Give me a bit to look through some people - I'll reach out when I've got someone worth meeting.",
                        isFromJules: true,
                        timestamp: Date()
                    )
                    viewModel.julesMessages.append(completionMessage)

                    // Delay then complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        onComplete()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Meet Jules") {
    MeetJulesView(onContinue: {})
}

#Preview("Jules Chat") {
    let vm = OnboardingViewModel()
    vm.julesMessages = [
        ChatMessage(
            id: "1",
            content: "Hey! I'm Jules, and I'm going to be your matchmaker. Think of me as the friend who's annoyingly good at knowing who you'd hit it off with.\n\nI've got the basics from your profile, but I want to go deeper. Ready?",
            isFromJules: true,
            timestamp: Date()
        )
    ]
    return JulesOnboardingChatView(viewModel: vm, onComplete: {})
}
