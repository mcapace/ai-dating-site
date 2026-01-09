//
//  Config.swift
//  ProjectJules
//
//  App Configuration - Uses environment variables for secure key management
//

import Foundation

enum Config {
    // MARK: - Supabase
    // Get these from: https://supabase.com/dashboard → Your Project → Settings → API
    // Or set via environment variables: SUPABASE_URL, SUPABASE_ANON_KEY
    static let supabaseURL: String = {
        // Try environment variable first (for CI/CD, secure builds)
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
            return url
        }
        // Fallback to hardcoded (public anon key is okay, but URL should be in env)
        // Note: Anon key is meant to be public, but for security, prefer env var
        return "https://qkegftjmzgtlecjvuhnl.supabase.co"
    }()
    
    static let supabaseAnonKey: String = {
        // Try environment variable first (more secure)
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"], !key.isEmpty {
            return key
        }
        // Fallback to hardcoded (anon key is meant to be public, but env var is preferred)
        // Note: Supabase anon key is safe to expose, but using env var is still better practice
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFrZWdmdGptemd0bGVjanZ1aG5sIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5OTIzMDUsImV4cCI6MjA4MzU2ODMwNX0.Qu6y2JcsZWwLM5q_35JrGLzdrbSjhsxDsP8WKCNmiXA"
    }()
    
    // MARK: - Anthropic (Claude AI)
    // Get this from: https://console.anthropic.com/ → API Keys → Create Key
    // IMPORTANT: Never commit real API keys! Always use environment variables.
    static let anthropicAPIKey: String = {
        // Try environment variable first (most secure)
        if let key = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"],
           !key.isEmpty && key != "YOUR_ANTHROPIC_API_KEY" {
            return key
        }
        // Fallback to Info.plist (if configured securely via build settings)
        if let key = Bundle.main.object(forInfoDictionaryKey: "AnthropicAPIKey") as? String,
           !key.isEmpty && key != "YOUR_ANTHROPIC_API_KEY" {
            return key
        }
        // No key found - return placeholder (app will fail API calls until key is set)
        // This forces developer to properly configure the key
        #if DEBUG
        print("⚠️ WARNING: ANTHROPIC_API_KEY not set. Claude API calls will fail.")
        print("   To fix: Xcode → Edit Scheme → Run → Arguments → Environment Variables")
        print("   Add: ANTHROPIC_API_KEY = your-actual-key")
        #endif
        return "YOUR_ANTHROPIC_API_KEY" // Placeholder - API calls will fail
    }()
    
    static let anthropicModel = "claude-sonnet-4-20250514"
    
    // MARK: - App Settings
    static let appName = "Jules"
    static let appVersion = "1.0.0"
    
    // MARK: - Twilio (SMS Verification - Optional)
    // Get these from: https://console.twilio.com/
    // Set via environment variables: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER
    static let twilioAccountSID: String = {
        ProcessInfo.processInfo.environment["TWILIO_ACCOUNT_SID"] ?? "YOUR_TWILIO_ACCOUNT_SID"
    }()
    
    static let twilioAuthToken: String = {
        ProcessInfo.processInfo.environment["TWILIO_AUTH_TOKEN"] ?? "YOUR_TWILIO_AUTH_TOKEN"
    }()
    
    static let twilioPhoneNumber: String = {
        ProcessInfo.processInfo.environment["TWILIO_PHONE_NUMBER"] ?? "+1234567890"
    }()
    
    // MARK: - Feature Flags
    static let enableVoiceNotes = true
    static let enableVideoCalls = false
    static let maxPhotosPerUser = 6
    
    // MARK: - Validation
    static func validate() -> Bool {
        // Check if required keys are set
        let hasAnthropicKey = !anthropicAPIKey.isEmpty && anthropicAPIKey != "YOUR_ANTHROPIC_API_KEY"
        let hasSupabaseURL = !supabaseURL.isEmpty && !supabaseURL.contains("YOUR_PROJECT_ID")
        let hasSupabaseKey = !supabaseAnonKey.isEmpty && !supabaseAnonKey.contains("YOUR_SUPABASE")
        
        guard hasSupabaseURL && hasSupabaseKey else {
            print("⚠️ Warning: Supabase credentials not properly configured")
            return false
        }
        
        guard hasAnthropicKey else {
            print("⚠️ Warning: Anthropic API key not set. Set ANTHROPIC_API_KEY environment variable or add to Info.plist")
            #if DEBUG
            print("   In Xcode: Edit Scheme → Run → Arguments → Environment Variables")
            print("   Add: ANTHROPIC_API_KEY = your-actual-key")
            #endif
            return false
        }
        
        return true
    }
}
