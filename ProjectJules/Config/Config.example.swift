//
//  Config.example.swift
//  ProjectJules
//
//  EXAMPLE CONFIG FILE - Copy this to Config.local.swift and add your keys
//  Config.local.swift is gitignored and will never be committed
//

import Foundation

// This is an example file. For secure key management:
// 1. Copy this to Config.local.swift (gitignored)
// 2. Replace placeholders with actual keys
// 3. Update Config.swift to import Config.local.swift if using this approach
// 
// OR better: Use environment variables (recommended)
// See SECURE_KEY_SETUP.md for instructions

enum ConfigExample {
    // MARK: - Supabase
    static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    // MARK: - Anthropic (Claude AI)
    static let anthropicAPIKey = "YOUR_ANTHROPIC_API_KEY"
    static let anthropicModel = "claude-sonnet-4-20250514"
    
    // MARK: - Twilio
    static let twilioAccountSID = "YOUR_TWILIO_ACCOUNT_SID"
    static let twilioAuthToken = "YOUR_TWILIO_AUTH_TOKEN"
    static let twilioPhoneNumber = "+1234567890"
}

