//
//  Config.swift
//  ProjectJules
//
//  App Configuration - Replace with your actual credentials
//

import Foundation

enum Config {
    // MARK: - Supabase
    // Project created automatically! Project: project-jules
    static let supabaseURL = "https://qkegftjmzgtlecjvuhnl.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrZWdmdGptemd0bGVjanZ1aG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5OTIzMDUsImV4cCI6MjA4MzU2ODMwNX0.Qu6y2JcsZWwLM5q_35JrGLzdrbSjhsxDsP8WKCNmiXA"
    
    // MARK: - Anthropic (Claude AI)
    // Get this from: https://console.anthropic.com/ → API Keys → Create Key
    // IMPORTANT: Never commit real API keys to git! Use environment variables or secure storage.
    static let anthropicAPIKey = "YOUR_ANTHROPIC_API_KEY" // TODO: Replace with actual key or use environment variable
    static let anthropicModel = "claude-sonnet-4-20250514"
    
    // MARK: - App Settings
    static let appName = "Jules"
    static let appVersion = "1.0.0"
    
    // MARK: - Twilio (SMS Verification - Optional)
    // Get these from: https://console.twilio.com/
    static let twilioAccountSID = "YOUR_TWILIO_ACCOUNT_SID"
    static let twilioAuthToken = "YOUR_TWILIO_AUTH_TOKEN"
    static let twilioPhoneNumber = "+1234567890"
    
    // MARK: - Feature Flags
    static let enableVoiceNotes = true
    static let enableVideoCalls = false
    static let maxPhotosPerUser = 6
    
    // MARK: - Validation
    static func validate() -> Bool {
        guard !supabaseURL.contains("YOUR_PROJECT_ID"),
              !supabaseAnonKey.contains("YOUR_SUPABASE"),
              !anthropicAPIKey.contains("YOUR_ANTHROPIC") else {
            print("⚠️ Warning: Config.swift contains placeholder values.")
            print("   Please update with your actual credentials:")
            print("   1. Supabase: https://supabase.com/dashboard → Settings → API")
            print("   2. Anthropic: https://console.anthropic.com/ → API Keys")
            return false
        }
        return true
    }
}
