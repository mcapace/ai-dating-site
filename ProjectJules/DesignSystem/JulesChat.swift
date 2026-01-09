//
//  JulesChat.swift
//  ProjectJules
//
//  Chat components: bubbles, typing indicator, voice notes
//

import SwiftUI

struct ChatBubble: View {
    let message: String
    let isFromJules: Bool
    let timestamp: Date
    
    var body: some View {
        HStack {
            if isFromJules {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isFromJules ? .trailing : .leading, spacing: Spacing.xs) {
                Text(message)
                    .font(.julBody())
                    .foregroundColor(isFromJules ? .white : .julTextPrimary)
                    .padding(Spacing.md)
                    .background(isFromJules ? Color.julTerracotta : Color.julCream)
                    .cornerRadius(Radius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.lg)
                            .stroke(Color.julBorder.opacity(0.3), lineWidth: isFromJules ? 0 : 1)
                    )
                
                Text(timestamp, style: .time)
                    .font(.julLabelSmall())
                    .foregroundColor(.julTextSecondary)
            }
            
            if !isFromJules {
                Spacer(minLength: 60)
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.julTerracotta)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .padding(Spacing.md)
        .background(Color.julCream)
        .cornerRadius(Radius.lg)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
    }
}

struct VoiceNoteView: View {
    let duration: TimeInterval
    let isPlaying: Bool
    let onPlay: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Button(action: isPlaying ? onStop : onPlay) {
                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.julTerracotta)
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Waveform visualization placeholder
                HStack(spacing: 2) {
                    ForEach(0..<20) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.julTerracotta)
                            .frame(width: 3, height: CGFloat.random(in: 4...20))
                    }
                }
                
                Text(formatDuration(duration))
                    .font(.julLabelSmall())
                    .foregroundColor(.julTextSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.julCream)
        .cornerRadius(Radius.lg)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollView {
                VStack(spacing: Spacing.md) {
                    ForEach(messages) { message in
                        ChatBubble(
                            message: message.text,
                            isFromJules: message.isFromJules,
                            timestamp: message.timestamp
                        )
                    }
                    
                    if isTyping {
                        HStack {
                            TypingIndicator()
                            Spacer(minLength: 60)
                        }
                    }
                }
                .padding(Spacing.md)
            }
            
            // Input
            HStack(spacing: Spacing.sm) {
                TextField("Type a message...", text: $inputText)
                    .font(.julBody())
                    .padding(Spacing.md)
                    .background(Color.julCream)
                    .cornerRadius(Radius.full)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(.julTerracotta)
                }
            }
            .padding(Spacing.md)
            .background(Color.julCardBackground)
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        // Implementation
        inputText = ""
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromJules: Bool
    let timestamp: Date
}

#Preview {
    ChatView()
}

