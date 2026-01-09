//
//  Typography.swift
//  ProjectJules
//
//  Typography system using Playfair Display and Inter
//

import SwiftUI

extension Font {
    // MARK: - Headlines (Playfair Display)
    static func julHeadline1() -> Font {
        .custom("PlayfairDisplay-SemiBold", size: 36)
    }
    
    static func julHeadline2() -> Font {
        .custom("PlayfairDisplay-SemiBold", size: 28)
    }
    
    static func julHeadline3() -> Font {
        .custom("PlayfairDisplay-SemiBold", size: 24)
    }
    
    static func julHeadline4() -> Font {
        .custom("PlayfairDisplay-Regular", size: 20)
    }
    
    // MARK: - Body (Inter)
    static func julBodyLarge() -> Font {
        .custom("Inter-Regular", size: 18)
    }
    
    static func julBody() -> Font {
        .custom("Inter-Regular", size: 16)
    }
    
    static func julBodySmall() -> Font {
        .custom("Inter-Regular", size: 14)
    }
    
    // MARK: - Labels
    static func julLabel() -> Font {
        .custom("Inter-Medium", size: 14)
    }
    
    static func julLabelSmall() -> Font {
        .custom("Inter-Medium", size: 12)
    }
    
    // MARK: - Buttons
    static func julButtonLarge() -> Font {
        .custom("Inter-SemiBold", size: 18)
    }
    
    static func julButton() -> Font {
        .custom("Inter-SemiBold", size: 16)
    }
    
    static func julButtonSmall() -> Font {
        .custom("Inter-SemiBold", size: 14)
    }
}

// Fallback fonts if custom fonts fail to load
extension Font {
    static func julHeadline1Fallback() -> Font {
        .system(size: 36, weight: .semibold, design: .serif)
    }
    
    static func julBodyFallback() -> Font {
        .system(size: 16, weight: .regular, design: .default)
    }
}

