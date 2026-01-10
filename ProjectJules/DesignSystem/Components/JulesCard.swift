//
//  JulesCard.swift
//  ProjectJules
//
//  Design System: Cards
//

import SwiftUI

// MARK: - Base Card
struct JulesCard<Content: View>: View {
    var padding: CGFloat = JulesSize.cardPadding
    var cornerRadius: CGFloat = JulesRadius.medium
    var shadow: JulesShadow = .card
    var backgroundColor: Color = .julCard
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .julesShadow(shadow)
    }
}

// MARK: - Match Card (The Hero Component)
struct MatchCard: View {
    let match: MatchPresentation
    var onAccept: () -> Void
    var onDecline: () -> Void
    var onSeeProfile: () -> Void

    @State private var currentPhotoIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            // Photo Carousel
            ZStack(alignment: .bottom) {
                TabView(selection: $currentPhotoIndex) {
                    ForEach(Array(match.photos.enumerated()), id: \.offset) { index, photo in
                        AsyncImage(url: URL(string: photo)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.julInputBackground)
                                .overlay(
                                    ProgressView()
                                        .tint(.julWarmGray)
                                )
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 320)

                // Photo Indicators
                HStack(spacing: 6) {
                    ForEach(0..<match.photos.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPhotoIndex ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 12)
            }
            .clipShape(
                RoundedCorner(radius: JulesRadius.medium, corners: [.topLeft, .topRight])
            )

            // Content
            VStack(alignment: .leading, spacing: JulesSpacing.md) {
                // Name and basic info
                VStack(alignment: .leading, spacing: 4) {
                    Text(match.name + ", " + String(match.age))
                        .font(.julTitle2)
                        .foregroundColor(.julWarmBlack)

                    Text(match.locationAndOccupation)
                        .font(.julBody)
                        .foregroundColor(.julWarmGray)
                }

                // Tags
                FlowLayout(spacing: JulesSpacing.xs) {
                    ForEach(match.tags, id: \.self) { tag in
                        JulesTag(text: tag)
                    }
                }

                // Why you might click section
                VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.julTerracotta)

                        Text("Why you might click")
                            .font(.julTag)
                            .foregroundColor(.julWarmBlack)
                    }

                    Text(match.compatibilityReason)
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                        .lineSpacing(3)
                }
                .padding(JulesSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient.julSparkGradient)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))

                // See full profile link
                Button(action: onSeeProfile) {
                    HStack(spacing: 4) {
                        Text("See full profile")
                            .font(.julBody)
                            .foregroundColor(.julTerracotta)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.julTerracotta)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(JulesSize.cardPadding)
            .background(Color.julCard)
        }
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
        .julesShadow(.card)
    }
}

// MARK: - Match Presentation Model
struct MatchPresentation: Identifiable {
    let id: String
    let name: String
    let age: Int
    let location: String
    let occupation: String
    let photos: [String]
    let tags: [String]
    let compatibilityReason: String
    let lookingFor: String
    let dealbreakers: [String]

    var locationAndOccupation: String {
        "\(location) · \(occupation)"
    }
}

// MARK: - Tag Component
struct JulesTag: View {
    let text: String
    var style: TagStyle = .default

    enum TagStyle {
        case `default`
        case highlighted
        case success
    }

    var body: some View {
        Text(text)
            .font(.julTag)
            .foregroundColor(textColor)
            .padding(.horizontal, JulesSpacing.sm)
            .padding(.vertical, JulesSpacing.xs)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
    }

    private var backgroundColor: Color {
        switch style {
        case .default: return .julInputBackground
        case .highlighted: return .julTerracotta.opacity(0.15)
        case .success: return .julSage.opacity(0.15)
        }
    }

    private var textColor: Color {
        switch style {
        case .default: return .julWarmBlack
        case .highlighted: return .julTerracotta
        case .success: return .julSage
        }
    }
}

// MARK: - Flow Layout (for tags)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

// MARK: - Rounded Corner Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Intro Card (List Item)
struct IntroListCard: View {
    let intro: IntroListItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: JulesSpacing.sm) {
                // Profile Photo
                AsyncImage(url: URL(string: intro.photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.julInputBackground)
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(intro.names)
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)

                        Spacer()

                        Text(intro.timestamp)
                            .font(.julCaption)
                            .foregroundColor(.julWarmGray)
                    }

                    Text(intro.preview)
                        .font(.julBody)
                        .foregroundColor(.julWarmGray)
                        .lineLimit(1)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.julWarmGray)
            }
            .padding(JulesSpacing.md)
            .background(Color.julCard)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IntroListItem: Identifiable {
    let id: String
    let names: String
    let photoURL: String
    let preview: String
    let timestamp: String
    let status: IntroStatus
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            MatchCard(
                match: MatchPresentation(
                    id: "1",
                    name: "Sarah",
                    age: 34,
                    location: "Brooklyn Heights",
                    occupation: "Lawyer",
                    photos: ["https://picsum.photos/400/500"],
                    tags: ["5'6\"", "No kids", "Active"],
                    compatibilityReason: "You both said dive bars over cocktail bars, and she hates small talk as much as you do.",
                    lookingFor: "Something serious, starting slow",
                    dealbreakers: []
                ),
                onAccept: {},
                onDecline: {},
                onSeeProfile: {}
            )

            IntroListCard(
                intro: IntroListItem(
                    id: "1",
                    names: "Sarah × Michael",
                    photoURL: "https://picsum.photos/100",
                    preview: "Spark Exchange in progress...",
                    timestamp: "Yesterday",
                    status: .sparkExchange
                ),
                action: {}
            )
        }
        .padding()
    }
    .background(Color.julCream)
}
