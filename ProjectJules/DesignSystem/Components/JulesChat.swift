//
//  JulesChat.swift
//  ProjectJules
//
//  Design System: Chat Components
//

import SwiftUI

// MARK: - Chat Message Bubble
struct ChatBubble: View {
    let message: ChatMessage
    var showAvatar: Bool = true

    var body: some View {
        HStack(alignment: .bottom, spacing: JulesSpacing.sm) {
            if message.isFromJules {
                // Jules Avatar
                if showAvatar {
                    JulesAvatar(size: 36)
                } else {
                    Spacer()
                        .frame(width: 36)
                }

                // Message
                VStack(alignment: .leading, spacing: JulesSpacing.xxs) {
                    Text(message.content)
                        .font(.julBodyLarge)
                        .foregroundColor(.julWarmBlack)
                        .lineSpacing(4)

                    if let timestamp = message.formattedTime {
                        Text(timestamp)
                            .font(.julCaption)
                            .foregroundColor(.julWarmGray)
                    }
                }
                .padding(JulesSpacing.md)
                .background(Color.julCard)
                .clipShape(ChatBubbleShape(isFromUser: false))
                .julesShadow(.button)

                Spacer(minLength: 60)
            } else {
                Spacer(minLength: 60)

                // User message
                VStack(alignment: .trailing, spacing: JulesSpacing.xxs) {
                    Text(message.content)
                        .font(.julBodyLarge)
                        .foregroundColor(.white)
                        .lineSpacing(4)

                    if let timestamp = message.formattedTime {
                        Text(timestamp)
                            .font(.julCaption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(JulesSpacing.md)
                .background(Color.julWarmBlack)
                .clipShape(ChatBubbleShape(isFromUser: true))
            }
        }
    }
}

// MARK: - Chat Bubble Shape
struct ChatBubbleShape: Shape {
    var isFromUser: Bool
    var cornerRadius: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isFromUser
                ? [.topLeft, .topRight, .bottomLeft]
                : [.topLeft, .topRight, .bottomRight],
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Equatable {
    let id: String
    let content: String
    let isFromJules: Bool
    let timestamp: Date
    var messageType: MessageType = .text
    var metadata: MessageMetadata? = nil

    enum MessageType {
        case text
        case matchCard
        case sparkPrompt
        case quickReplies
        case dateConfirmation
        case voiceNote
    }

    var formattedTime: String? {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct MessageMetadata {
    var matchId: String?
    var quickReplies: [String]?
    var promptText: String?
    var voiceNoteURL: String?
    var voiceNoteDuration: TimeInterval?
}

// MARK: - Jules Avatar
struct JulesAvatar: View {
    var size: CGFloat = 44
    var state: JulesState = .neutral
    var showRing: Bool = false

    enum JulesState {
        case neutral
        case thinking
        case excited
        case empathetic
    }

    var body: some View {
        ZStack {
            // Glow ring when active
            if showRing {
                Circle()
                    .fill(Color.julTerracotta.opacity(0.2))
                    .frame(width: size + 8, height: size + 8)
            }

            // Avatar background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "F7E6DC"), Color(hex: "E6D5C8")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Jules initial (placeholder until we have actual avatar)
            Text("J")
                .font(.system(size: size * 0.4, weight: .semibold, design: .serif))
                .foregroundColor(.julTerracotta)
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        HStack(alignment: .bottom, spacing: JulesSpacing.sm) {
            JulesAvatar(size: 36, state: .thinking)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.julWarmGray)
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset(for: index))
                }
            }
            .padding(.horizontal, JulesSpacing.md)
            .padding(.vertical, JulesSpacing.sm)
            .background(Color.julCard)
            .clipShape(ChatBubbleShape(isFromUser: false))
            .julesShadow(.button)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                animationOffset = 1
            }
        }
    }

    private func animationOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.15
        let progress = (animationOffset + CGFloat(delay)).truncatingRemainder(dividingBy: 1)
        return -4 * sin(progress * .pi)
    }
}

// MARK: - Quick Reply Buttons
struct QuickReplyButtons: View {
    let options: [String]
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: JulesSpacing.sm) {
                ForEach(options, id: \.self) { option in
                    Button(action: { onSelect(option) }) {
                        Text(option)
                            .font(.julBody)
                            .foregroundColor(.julTerracotta)
                            .padding(.horizontal, JulesSpacing.md)
                            .padding(.vertical, JulesSpacing.sm)
                            .background(Color.julTerracotta.opacity(0.1))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.julTerracotta, lineWidth: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
        }
    }
}

// MARK: - Chat Input Bar
struct ChatInputBar: View {
    @Binding var text: String
    var placeholder: String = "Type a message..."
    var showVoiceButton: Bool = false
    var onSend: () -> Void
    var onVoiceRecord: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: JulesSpacing.sm) {
            // Text Input
            HStack(spacing: JulesSpacing.sm) {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(.julBody)
                    .foregroundColor(.julWarmBlack)
                    .lineLimit(1...5)
                    .focused($isFocused)

                if showVoiceButton && text.isEmpty {
                    Button(action: { onVoiceRecord?() }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.julWarmGray)
                    }
                }
            }
            .padding(.horizontal, JulesSpacing.md)
            .padding(.vertical, JulesSpacing.sm)
            .background(Color.julInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            // Send Button
            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(text.isEmpty ? Color.julWarmGray : Color.julWarmBlack)
                    .clipShape(Circle())
            }
            .disabled(text.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        }
        .padding(.horizontal, JulesSpacing.screen)
        .padding(.vertical, JulesSpacing.sm)
        .background(Color.julCream)
    }
}

// MARK: - Voice Note Player
struct VoiceNotePlayer: View {
    let duration: TimeInterval
    var isPlaying: Bool = false
    var progress: Double = 0
    var onPlayPause: () -> Void

    var body: some View {
        HStack(spacing: JulesSpacing.sm) {
            Button(action: onPlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.julTerracotta)
                    .frame(width: 32, height: 32)
                    .background(Color.julTerracotta.opacity(0.15))
                    .clipShape(Circle())
            }

            // Waveform visualization (simplified)
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(0..<30, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 1)
                            .fill(Double(index) / 30.0 < progress ? Color.julTerracotta : Color.julWarmGray.opacity(0.3))
                            .frame(width: 3, height: waveformHeight(for: index))
                    }
                }
                .frame(height: 24)
            }
            .frame(height: 24)

            Text(formatDuration(duration))
                .font(.julCaption)
                .foregroundColor(.julWarmGray)
        }
        .padding(JulesSpacing.sm)
        .background(Color.julInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
    }

    private func waveformHeight(for index: Int) -> CGFloat {
        // Pseudo-random heights for visual effect
        let heights: [CGFloat] = [8, 16, 12, 20, 14, 24, 10, 18, 22, 8, 16, 20, 12, 18, 24, 10, 14, 22, 8, 16, 12, 20, 18, 10, 24, 14, 8, 16, 20, 12]
        return heights[index % heights.count]
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ScrollView {
            VStack(spacing: JulesSpacing.md) {
                ChatBubble(
                    message: ChatMessage(
                        id: "1",
                        content: "Hey! I'm Jules, and I'm going to be your matchmaker. Think of me as the friend who's annoyingly good at knowing who you'd hit it off with.",
                        isFromJules: true,
                        timestamp: Date()
                    )
                )

                ChatBubble(
                    message: ChatMessage(
                        id: "2",
                        content: "That sounds great! I'm excited to get started.",
                        isFromJules: false,
                        timestamp: Date()
                    )
                )

                TypingIndicator()

                QuickReplyButtons(
                    options: ["Let's go", "Tell me more", "Not right now"],
                    onSelect: { _ in }
                )
            }
            .padding()
        }

        Spacer()

        ChatInputBar(
            text: .constant(""),
            showVoiceButton: true,
            onSend: {}
        )
    }
    .background(Color.julCream)
}
