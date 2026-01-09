//
//  AuthService.swift
//  ProjectJules
//
//  Authentication service for phone/OTP
//

import Foundation
import Supabase

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        Task {
            do {
                let session = try await supabase.auth.session
                if let user = session.user {
                    await loadUser(userId: user.id)
                } else {
                    isAuthenticated = false
                    currentUser = nil
                }
            } catch {
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    func sendOTP(phone: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let phoneFormatted = formatPhone(phone)
            try await supabase.auth.signInWithOTP(phone: phoneFormatted)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to send verification code: \(error.localizedDescription)"
            throw error
        }
    }
    
    func verifyOTP(phone: String, token: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let phoneFormatted = formatPhone(phone)
            let session = try await supabase.auth.verifyOTP(phone: phoneFormatted, token: token, type: .sms)
            
            if let user = session.user {
                await loadUser(userId: user.id)
                isAuthenticated = true
            }
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Invalid verification code"
            throw error
        }
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    private func loadUser(userId: UUID) async {
        do {
            let response: User = try await supabase.client.database
                .from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            currentUser = response
        } catch {
            print("Error loading user: \(error)")
        }
    }
    
    private func formatPhone(_ phone: String) -> String {
        let cleaned = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if cleaned.hasPrefix("1") && cleaned.count == 11 {
            return "+\(cleaned)"
        } else if cleaned.count == 10 {
            return "+1\(cleaned)"
        }
        return phone
    }
}

