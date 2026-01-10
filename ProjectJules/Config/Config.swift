//
//  Config.swift
//  ProjectJules
//
//  App Configuration - Replace with your actual credentials
//

import Foundation

enum Config {
    // MARK: - Supabase
    // Reads from environment variable first, falls back to hardcoded value
    static var supabaseURL: String {
        ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://YOUR_PROJECT_ID.supabase.co"
    }
    
    static var supabaseAnonKey: String {
        ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "YOUR_SUPABASE_ANON_KEY"
    }

    // MARK: - Anthropic (Claude AI)
    // Reads from environment variable first, falls back to hardcoded value
    static var anthropicAPIKey: String {
        ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"] ?? "YOUR_ANTHROPIC_API_KEY"
    }
    static let anthropicModel = "claude-sonnet-4-20250514"

    // MARK: - App Settings
    static let appName = "Jules"
    static let appTagline = "Your AI Matchmaker"
    static let supportEmail = "support@projectjules.app"
    static let privacyURL = URL(string: "https://projectjules.app/privacy")!
    static let termsURL = URL(string: "https://projectjules.app/terms")!

    // MARK: - Matching Settings
    static let maxDailyMatches = 3
    static let sparkExchangePromptCount = 3
    static let schedulingWindowDays = 14

    // MARK: - Subscription
    static let monthlyPriceUSD = 35.00
    static let annualPriceUSD = 280.00
    static let monthlyProductID = "com.projectjules.premium.monthly"
    static let annualProductID = "com.projectjules.premium.annual"

    // MARK: - Feature Flags
    static let enableVoiceNotes = true
    static let enablePremiumFeatures = true
    static let debugMode = false
}

// MARK: - Environment-Specific Config
extension Config {
    enum Environment {
        case development
        case staging
        case production
    }

    static var currentEnvironment: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    static var baseURL: String {
        switch currentEnvironment {
        case .development:
            return "https://dev.projectjules.app"
        case .staging:
            return "https://staging.projectjules.app"
        case .production:
            return "https://projectjules.app"
        }
    }
}
