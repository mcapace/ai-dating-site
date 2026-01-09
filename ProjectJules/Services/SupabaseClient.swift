//
//  SupabaseClient.swift
//  ProjectJules
//
//  Supabase client configuration
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        guard let url = URL(string: Config.supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Config.supabaseAnonKey
        )
    }
    
    // Convenience accessors
    var auth: AuthClient {
        client.auth
    }
    
    // Access database and storage directly through client
    // (Types are inferred from Supabase SDK)
}

