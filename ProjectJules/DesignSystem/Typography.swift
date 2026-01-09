//
//  Typography.swift
//  ProjectJules
//
//  Design System: Typography
//

import SwiftUI

// MARK: - Font Names
enum JulesFont {
    static let serifRegular = "PlayfairDisplay-Regular"
    static let serifMedium = "PlayfairDisplay-Medium"
    static let serifSemiBold = "PlayfairDisplay-SemiBold"
    static let serifBold = "PlayfairDisplay-Bold"

    static let sansRegular = "Inter-Regular"
    static let sansMedium = "Inter-Medium"
    static let sansSemiBold = "Inter-SemiBold"
    static let sansBold = "Inter-Bold"
}

// MARK: - Typography Styles
extension Font {

    // MARK: Headlines (Playfair Display)

    /// Hero text - 34pt Medium
    /// Usage: Main screen titles, match names
    static let julHero = Font.custom(JulesFont.serifMedium, size: 34)

    /// Title 1 - 28pt Medium
    /// Usage: Section headers, onboarding titles
    static let julTitle1 = Font.custom(JulesFont.serifMedium, size: 28)

    /// Title 2 - 22pt Medium
    /// Usage: Card titles, feature headers
    static let julTitle2 = Font.custom(JulesFont.serifMedium, size: 22)

    /// Title 3 - 18pt SemiBold (Inter)
    /// Usage: Subsections, list headers
    static let julTitle3 = Font.custom(JulesFont.sansSemiBold, size: 18)

    // MARK: Body Text (Inter)

    /// Body Large - 17pt Regular
    /// Usage: Jules messages, important content
    static let julBodyLarge = Font.custom(JulesFont.sansRegular, size: 17)

    /// Body - 15pt Regular
    /// Usage: Standard body text
    static let julBody = Font.custom(JulesFont.sansRegular, size: 15)

    /// Body Small - 13pt Regular
    /// Usage: Secondary info, captions
    static let julBodySmall = Font.custom(JulesFont.sansRegular, size: 13)

    // MARK: UI Elements (Inter)

    /// Button text - 15pt SemiBold
    static let julButton = Font.custom(JulesFont.sansSemiBold, size: 15)

    /// Caption - 11pt Medium
    /// Usage: Timestamps, labels, metadata
    static let julCaption = Font.custom(JulesFont.sansMedium, size: 11)

    /// Tag - 13pt Medium
    /// Usage: Chips, tags, badges
    static let julTag = Font.custom(JulesFont.sansMedium, size: 13)

    /// Input - 15pt Regular
    /// Usage: Text fields, input areas
    static let julInput = Font.custom(JulesFont.sansRegular, size: 15)
}

// MARK: - Fallback to System Fonts
/// Use these if custom fonts aren't loaded
extension Font {
    static let julHeroFallback = Font.system(size: 34, weight: .medium, design: .serif)
    static let julTitle1Fallback = Font.system(size: 28, weight: .medium, design: .serif)
    static let julTitle2Fallback = Font.system(size: 22, weight: .medium, design: .serif)
    static let julTitle3Fallback = Font.system(size: 18, weight: .semibold)
    static let julBodyLargeFallback = Font.system(size: 17, weight: .regular)
    static let julBodyFallback = Font.system(size: 15, weight: .regular)
    static let julBodySmallFallback = Font.system(size: 13, weight: .regular)
    static let julButtonFallback = Font.system(size: 15, weight: .semibold)
    static let julCaptionFallback = Font.system(size: 11, weight: .medium)
}

// MARK: - Text Styles
struct JulesTextStyle: ViewModifier {
    enum Style {
        case hero
        case title1
        case title2
        case title3
        case bodyLarge
        case body
        case bodySmall
        case button
        case caption
        case tag
    }

    let style: Style
    var color: Color = .julWarmBlack

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
            .lineSpacing(lineSpacing)
    }

    private var font: Font {
        switch style {
        case .hero: return .julHero
        case .title1: return .julTitle1
        case .title2: return .julTitle2
        case .title3: return .julTitle3
        case .bodyLarge: return .julBodyLarge
        case .body: return .julBody
        case .bodySmall: return .julBodySmall
        case .button: return .julButton
        case .caption: return .julCaption
        case .tag: return .julTag
        }
    }

    private var lineSpacing: CGFloat {
        switch style {
        case .hero, .title1, .title2, .title3:
            return 2
        case .bodyLarge:
            return 4
        case .body, .bodySmall:
            return 3
        case .button, .caption, .tag:
            return 0
        }
    }
}

// MARK: - View Extension
extension View {
    func julText(_ style: JulesTextStyle.Style, color: Color = .julWarmBlack) -> some View {
        modifier(JulesTextStyle(style: style, color: color))
    }
}

// MARK: - Text Extension for Easy Styling
extension Text {
    func julStyle(_ style: JulesTextStyle.Style) -> Text {
        switch style {
        case .hero:
            return self.font(.julHero)
        case .title1:
            return self.font(.julTitle1)
        case .title2:
            return self.font(.julTitle2)
        case .title3:
            return self.font(.julTitle3)
        case .bodyLarge:
            return self.font(.julBodyLarge)
        case .body:
            return self.font(.julBody)
        case .bodySmall:
            return self.font(.julBodySmall)
        case .button:
            return self.font(.julButton)
        case .caption:
            return self.font(.julCaption)
        case .tag:
            return self.font(.julTag)
        }
    }
}
