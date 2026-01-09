//
//  JulesCard.swift
//  ProjectJules
//
//  Card component for matches, intros, and content
//

import SwiftUI

struct JulesCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = Spacing.md
    var cornerRadius: CGFloat = Radius.lg
    
    init(padding: CGFloat = Spacing.md, cornerRadius: CGFloat = Radius.lg, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color.julCardBackground)
            .cornerRadius(cornerRadius)
            .julShadow(Shadow.md)
    }
}

// Match Card
struct MatchCard: View {
    let match: Match
    let onTap: () -> Void
    
    var body: some View {
        JulesCard {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Photo gallery placeholder
                RoundedRectangle(cornerRadius: Radius.md)
                    .fill(Color.julCream)
                    .frame(height: 300)
                    .overlay(
                        Text("Photo Gallery")
                            .font(.julBodySmall())
                            .foregroundColor(.julTextSecondary)
                    )
                
                Text(match.userName)
                    .font(.julHeadline3())
                    .foregroundColor(.julTextPrimary)
                
                if let bio = match.bio {
                    Text(bio)
                        .font(.julBodySmall())
                        .foregroundColor(.julTextSecondary)
                        .lineLimit(2)
                }
            }
        }
        .onTapGesture(perform: onTap)
    }
}

// Intro Card
struct IntroCard: View {
    let intro: Intro
    let onTap: () -> Void
    
    var body: some View {
        JulesCard {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Jules says:")
                    .font(.julLabel())
                    .foregroundColor(.julTerracotta)
                
                Text(intro.julesMessage)
                    .font(.julBody())
                    .foregroundColor(.julTextPrimary)
                
                HStack {
                    Spacer()
                    Text(intro.createdAt, style: .relative)
                        .font(.julBodySmall())
                        .foregroundColor(.julTextSecondary)
                }
            }
        }
        .onTapGesture(perform: onTap)
    }
}

// Tag View
struct TagView: View {
    let text: String
    var isSelected: Bool = false
    
    var body: some View {
        Text(text)
            .font(.julLabelSmall())
            .foregroundColor(isSelected ? .white : .julTextPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .background(isSelected ? Color.julTerracotta : Color.julCream)
            .cornerRadius(Radius.full)
    }
}

// Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = Spacing.sm
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var frames: [CGRect] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.frames = frames
            self.size = CGSize(
                width: maxWidth,
                height: currentY + lineHeight
            )
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        MatchCard(match: Match.preview) {}
        IntroCard(intro: Intro.preview) {}
        
        FlowLayout(spacing: Spacing.sm) {
            TagView(text: "Coffee")
            TagView(text: "Art", isSelected: true)
            TagView(text: "Travel")
            TagView(text: "Music")
        }
    }
    .padding()
}

