//
//  AuthService.swift
//  ProjectJules
//
//  Authentication Service (Phone/SMS via Supabase)
//

import Foundation
import Supabase
import Combine

// MARK: - Auth Service
@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: AuthError?

    private let supabase = SupabaseManager.shared.client
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupAuthStateListener()
    }

    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        Task {
            for await state in supabase.auth.authStateChanges {
                switch state.event {
                case .initialSession, .signedIn:
                    if let session = state.session {
                        await handleSignIn(userId: session.user.id.uuidString)
                    }
                case .signedOut:
                    handleSignOut()
                default:
                    break
                }
            }
        }
    }

    // MARK: - Check Session
    func checkSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.session
            await handleSignIn(userId: session.user.id.uuidString)
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }

    // MARK: - Send OTP (Phone Verification)
    func sendOTP(phone: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            // Format phone number
            let formattedPhone = formatPhoneNumber(phone)

            try await supabase.auth.signInWithOTP(
                phone: formattedPhone
            )
        } catch {
            self.error = .otpFailed(error.localizedDescription)
            throw AuthError.otpFailed(error.localizedDescription)
        }
    }

    // MARK: - Verify OTP
    func verifyOTP(phone: String, code: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let formattedPhone = formatPhoneNumber(phone)

            let response = try await supabase.auth.verifyOTP(
                phone: formattedPhone,
                token: code,
                type: .sms
            )

            await handleSignIn(userId: response.user.id.uuidString)
        } catch {
            self.error = .verificationFailed(error.localizedDescription)
            throw AuthError.verificationFailed(error.localizedDescription)
        }
    }

    // MARK: - Sign Out
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            try await supabase.auth.signOut()
            handleSignOut()
        } catch {
            self.error = .signOutFailed(error.localizedDescription)
            throw AuthError.signOutFailed(error.localizedDescription)
        }
    }

    // MARK: - Handle Sign In
    private func handleSignIn(userId: String) async {
        isAuthenticated = true

        // Fetch user data
        do {
            let user: User = try await SupabaseManager.shared
                .from(.users)
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            currentUser = user

            // Fetch profile if exists
            if let profile: UserProfile = try? await SupabaseManager.shared
                .from(.userProfiles)
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value {
                currentProfile = profile
            }
        } catch {
            // User doesn't exist yet, create them
            await createNewUser(userId: userId)
        }
    }

    // MARK: - Create New User
    private func createNewUser(userId: String) async {
        do {
            let phone = try await supabase.auth.session.user.phone ?? ""

            let newUser = User(
                id: userId,
                phone: phone,
                email: nil,
                createdAt: Date(),
                updatedAt: Date(),
                lastActiveAt: Date(),
                status: .onboarding,
                subscriptionTier: .free,
                subscriptionExpiresAt: nil
            )

            try await SupabaseManager.shared
                .from(.users)
                .insert(newUser)
                .execute()

            currentUser = newUser
        } catch {
            self.error = .userCreationFailed(error.localizedDescription)
        }
    }

    // MARK: - Handle Sign Out
    private func handleSignOut() {
        isAuthenticated = false
        currentUser = nil
        currentProfile = nil
    }

    // MARK: - Phone Number Formatting
    private func formatPhoneNumber(_ phone: String) -> String {
        // Remove all non-numeric characters
        let digits = phone.filter { $0.isNumber }

        // Add country code if not present
        if digits.hasPrefix("1") && digits.count == 11 {
            return "+\(digits)"
        } else if digits.count == 10 {
            return "+1\(digits)"
        }

        return "+\(digits)"
    }

    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // Delete user data (cascade should handle related records)
            try await SupabaseManager.shared
                .from(.users)
                .delete()
                .eq("id", value: userId)
                .execute()

            // Sign out
            try await signOut()
        } catch {
            self.error = .deleteFailed(error.localizedDescription)
            throw AuthError.deleteFailed(error.localizedDescription)
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case notAuthenticated
    case otpFailed(String)
    case verificationFailed(String)
    case signOutFailed(String)
    case userCreationFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .otpFailed(let message):
            return "Failed to send verification code: \(message)"
        case .verificationFailed(let message):
            return "Verification failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .userCreationFailed(let message):
            return "Account creation failed: \(message)"
        case .deleteFailed(let message):
            return "Account deletion failed: \(message)"
        }
    }
}
