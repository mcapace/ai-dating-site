//
//  OnboardingFlowView.swift
//  ProjectJules
//
//  Main Onboarding Flow Container
//

import SwiftUI

// MARK: - Onboarding Flow
struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.julCream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator (except on welcome)
                if viewModel.currentStep != .welcome {
                    OnboardingProgress(
                        currentStep: viewModel.currentStep.rawValue,
                        totalSteps: OnboardingStep.allCases.count - 1
                    )
                    .padding(.top, JulesSpacing.md)
                }

                // Current step content
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        WelcomeView(onContinue: viewModel.nextStep)

                    case .phone:
                        PhoneInputView(viewModel: viewModel)

                    case .verification:
                        VerificationView(viewModel: viewModel)

                    case .basicInfo:
                        BasicInfoView(viewModel: viewModel)

                    case .photos:
                        PhotosView(viewModel: viewModel)

                    case .lookingFor:
                        LookingForView(viewModel: viewModel)

                    case .moreDetails:
                        MoreDetailsView(viewModel: viewModel)

                    case .neighborhoods:
                        NeighborhoodsView(viewModel: viewModel)

                    case .meetJules:
                        MeetJulesView(onContinue: viewModel.nextStep)

                    case .julesChat:
                        JulesOnboardingChatView(viewModel: viewModel) {
                            completeOnboarding()
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentStep)
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    private func completeOnboarding() {
        Task {
            await viewModel.completeOnboarding()
            await MainActor.run {
                withAnimation {
                    appState.currentFlow = .main
                }
            }
        }
    }
}

// MARK: - Onboarding Progress
struct OnboardingProgress: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color.julTerracotta : Color.julDivider)
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, JulesSpacing.screen)
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case phone
    case verification
    case basicInfo
    case photos
    case lookingFor
    case moreDetails
    case neighborhoods
    case meetJules
    case julesChat
}

// MARK: - Onboarding View Model
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isLoading = false
    @Published var error: String?

    // Phone/Auth
    @Published var phoneNumber = ""
    @Published var verificationCode = ""

    // Basic Info
    @Published var firstName = ""
    @Published var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @Published var gender: Gender = .man

    // Photos
    @Published var photos: [UIImage] = []

    // Looking For
    @Published var genderPreference: Set<Gender> = []
    @Published var ageMin: Double = 25
    @Published var ageMax: Double = 45

    // More Details
    @Published var heightInches: Int?
    @Published var hasChildren: Bool?
    @Published var occupation = ""

    // Neighborhoods
    @Published var selectedNeighborhoods: Set<String> = []
    @Published var availableNeighborhoods: [Neighborhood] = []

    // Jules Chat
    @Published var julesMessages: [ChatMessage] = []
    @Published var currentJulesQuestion = 0
    @Published var onboardingAnswers: [String: String] = [:]

    private let authService = AuthService.shared
    private let userService = UserService.shared
    private let julesService = JulesService.shared
    private let neighborhoodService = NeighborhoodService.shared

    // MARK: - Navigation

    func nextStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = nextStep
    }

    func previousStep() {
        guard let prevStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prevStep
    }

    // MARK: - Phone Verification

    func sendOTP() async {
        isLoading = true
        error = nil

        do {
            try await authService.sendOTP(phone: phoneNumber)
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func verifyOTP() async {
        isLoading = true
        error = nil

        do {
            try await authService.verifyOTP(phone: phoneNumber, code: verificationCode)
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Profile Creation

    func saveBasicInfo() async {
        guard let userId = authService.currentUser?.id else {
            error = "Not authenticated"
            return
        }

        isLoading = true

        do {
            _ = try await userService.createProfile(
                userId: userId,
                firstName: firstName,
                birthdate: birthDate,
                gender: gender
            )
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func uploadPhotos() async {
        guard let userId = authService.currentUser?.id else {
            error = "Not authenticated"
            return
        }

        isLoading = true

        do {
            for (index, image) in photos.enumerated() {
                _ = try await userService.uploadPhoto(
                    userId: userId,
                    image: image,
                    position: index + 1
                )
            }
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func savePreferences() async {
        guard let userId = authService.currentUser?.id else {
            error = "Not authenticated"
            return
        }

        isLoading = true

        do {
            _ = try await userService.createPreferences(
                userId: userId,
                genderPreference: Array(genderPreference),
                ageMin: Int(ageMin),
                ageMax: Int(ageMax)
            )
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func saveMoreDetails() async {
        guard let userId = authService.currentUser?.id else {
            error = "Not authenticated"
            return
        }

        isLoading = true

        do {
            var profile = try await userService.getProfile(userId: userId)
            profile.heightInches = heightInches
            profile.hasChildren = hasChildren
            profile.occupation = occupation.isEmpty ? nil : occupation

            try await userService.updateProfile(profile)
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Neighborhoods

    func loadNeighborhoods() async {
        do {
            let neighborhoods = try await neighborhoodService.getNeighborhoods(cityId: "nyc")
            await MainActor.run {
                availableNeighborhoods = neighborhoods
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func saveNeighborhoods() async {
        guard let userId = authService.currentUser?.id else {
            error = "Not authenticated"
            return
        }

        isLoading = true

        do {
            try await userService.setNeighborhoods(
                userId: userId,
                neighborhoodIds: Array(selectedNeighborhoods)
            )
            await MainActor.run {
                nextStep()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Jules Onboarding Chat

    func startJulesChat() async {
        guard let userId = authService.currentUser?.id else { return }

        do {
            let conversation = try await julesService.getOrCreateConversation(userId: userId)

            // Get first question
            let message = try await julesService.getOnboardingQuestion(
                conversationId: conversation.id,
                userId: userId,
                questionIndex: 0,
                previousAnswers: [:]
            )

            await MainActor.run {
                julesMessages.append(ChatMessage(
                    id: message.id,
                    content: message.content,
                    isFromJules: true,
                    timestamp: message.createdAt
                ))
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func sendJulesAnswer(_ answer: String) async {
        guard let userId = authService.currentUser?.id else { return }

        // Add user message
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: answer,
            isFromJules: false,
            timestamp: Date()
        )

        await MainActor.run {
            julesMessages.append(userMessage)
            onboardingAnswers["question_\(currentJulesQuestion)"] = answer
            currentJulesQuestion += 1
        }

        // Check if onboarding is complete (7 questions)
        if currentJulesQuestion >= 7 {
            return // Signal completion
        }

        do {
            let conversation = try await julesService.getOrCreateConversation(userId: userId)

            let message = try await julesService.getOnboardingQuestion(
                conversationId: conversation.id,
                userId: userId,
                questionIndex: currentJulesQuestion,
                previousAnswers: onboardingAnswers
            )

            await MainActor.run {
                julesMessages.append(ChatMessage(
                    id: message.id,
                    content: message.content,
                    isFromJules: true,
                    timestamp: message.createdAt
                ))
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() async {
        guard let userId = authService.currentUser?.id else { return }

        isLoading = true

        do {
            try await userService.completeOnboarding(userId: userId)
            await authService.checkSession() // Refresh user state
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - Preview
#Preview {
    OnboardingFlowView()
        .environmentObject(AppState())
        .environmentObject(AuthService.shared)
}
