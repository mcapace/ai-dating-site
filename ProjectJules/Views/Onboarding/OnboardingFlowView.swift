//
//  OnboardingFlowView.swift
//  ProjectJules
//
//  Onboarding flow coordinator
//

import SwiftUI
import UIKit

struct OnboardingFlowView: View {
    @StateObject private var authService = AuthService()
    @State private var currentStep: OnboardingStep = .welcome
    @State private var phoneNumber: String = ""
    @State private var otpCode: String = ""
    
    enum OnboardingStep {
        case welcome
        case phoneVerification
        case otpVerification
        case basicInfo
        case preferences
        case photos
        case neighborhoods
        case julesIntro
    }
    
    var body: some View {
        ZStack {
            Color.julBackground
                .ignoresSafeArea()
            
            switch currentStep {
            case .welcome:
                WelcomeView(onContinue: {
                    currentStep = .phoneVerification
                })
            case .phoneVerification:
                PhoneVerificationView(
                    phoneNumber: $phoneNumber,
                    onSendCode: {
                        Task {
                            try? await authService.sendOTP(phone: phoneNumber)
                            currentStep = .otpVerification
                        }
                    }
                )
            case .otpVerification:
                OTPVerificationView(
                    code: $otpCode,
                    phoneNumber: phoneNumber,
                    onVerify: {
                        Task {
                            try? await authService.verifyOTP(phone: phoneNumber, token: otpCode)
                            if authService.isAuthenticated {
                                currentStep = .basicInfo
                            }
                        }
                    }
                )
            case .basicInfo:
                BasicInfoView(onContinue: {
                    currentStep = .preferences
                })
            case .preferences:
                PreferencesView(onContinue: {
                    currentStep = .photos
                })
            case .photos:
                PhotosView(onContinue: {
                    currentStep = .neighborhoods
                })
            case .neighborhoods:
                NeighborhoodsView(onContinue: {
                    currentStep = .julesIntro
                })
            case .julesIntro:
                JulesIntroView(onComplete: {
                    // Onboarding complete
                })
            }
        }
    }
}

struct WelcomeView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Text("Welcome to Jules")
                .font(.julHeadline1())
                .foregroundColor(.julTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("Your AI-powered dating assistant")
                .font(.julBodyLarge())
                .foregroundColor(.julTextSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            JulesButton(title: "Get Started", style: .primary) {
                onContinue()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
}

struct PhoneVerificationView: View {
    @Binding var phoneNumber: String
    let onSendCode: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Text("Enter Your Phone Number")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xxl)
                
                PhoneInputView(phoneNumber: $phoneNumber, onSendCode: onSendCode)
                    .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

struct OTPVerificationView: View {
    @Binding var code: String
    let phoneNumber: String
    let onVerify: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                Text("Enter Verification Code")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xxl)
                
                Text("We sent a code to \(phoneNumber)")
                    .font(.julBody())
                    .foregroundColor(.julTextSecondary)
                
                OTPInputView(code: $code)
                    .padding(.horizontal, Spacing.lg)
                
                JulesButton(title: "Verify", style: .primary) {
                    onVerify()
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

struct BasicInfoView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var bio: String = ""
    
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                Text("Tell Us About Yourself")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xl)
                
                JulesTextField(title: "First Name", text: $firstName, placeholder: "Enter your first name")
                JulesTextField(title: "Last Name", text: $lastName, placeholder: "Enter your last name")
                
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    .font(.julBody())
                    .padding(Spacing.md)
                    .background(Color.julCream)
                    .cornerRadius(Radius.md)
                
                JulesTextField(title: "Bio", text: $bio, placeholder: "Tell us about yourself")
                
                JulesButton(title: "Continue", style: .primary) {
                    onContinue()
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}

struct PreferencesView: View {
    @State private var ageMin: Int = 18
    @State private var ageMax: Int = 99
    @State private var selectedInterests: Set<String> = []
    
    let interests = ["Coffee", "Art", "Travel", "Music", "Food", "Sports", "Reading", "Movies"]
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Your Preferences")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xl)
                
                Text("Age Range")
                    .font(.julLabel())
                    .foregroundColor(.julTextPrimary)
                
                HStack {
                    Text("\(ageMin)")
                    Slider(value: Binding(
                        get: { Double(ageMin) },
                        set: { ageMin = Int($0) }
                    ), in: 18...99)
                    Text("\(ageMax)")
                }
                
                Text("Interests")
                    .font(.julLabel())
                    .foregroundColor(.julTextPrimary)
                
                FlowLayout(spacing: Spacing.sm) {
                    ForEach(interests, id: \.self) { interest in
                        TagView(text: interest, isSelected: selectedInterests.contains(interest))
                            .onTapGesture {
                                if selectedInterests.contains(interest) {
                                    selectedInterests.remove(interest)
                                } else {
                                    selectedInterests.insert(interest)
                                }
                            }
                    }
                }
                
                JulesButton(title: "Continue", style: .primary) {
                    onContinue()
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}

struct PhotosView: View {
    @State private var photos: [UIImage] = []
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                Text("Add Photos")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xl)
                
                Text("Add at least one photo to get started")
                    .font(.julBodySmall())
                    .foregroundColor(.julTextSecondary)
                
                // Photo grid placeholder
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                    ForEach(0..<6) { index in
                        RoundedRectangle(cornerRadius: Radius.md)
                            .fill(Color.julCream)
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.julTextSecondary)
                            )
                    }
                }
                .padding(.horizontal, Spacing.lg)
                
                JulesButton(title: "Continue", style: .primary) {
                    onContinue()
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

struct NeighborhoodsView: View {
    @State private var selectedNeighborhoods: Set<UUID> = []
    let onContinue: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("Select Neighborhoods")
                    .font(.julHeadline2())
                    .foregroundColor(.julTextPrimary)
                    .padding(.top, Spacing.xl)
                
                Text("Where do you want to meet people?")
                    .font(.julBodySmall())
                    .foregroundColor(.julTextSecondary)
                
                // Neighborhood list placeholder
                ForEach(["SoHo", "West Village", "East Village", "Williamsburg"], id: \.self) { neighborhood in
                    HStack {
                        Text(neighborhood)
                            .font(.julBody())
                            .foregroundColor(.julTextPrimary)
                        Spacer()
                        Image(systemName: selectedNeighborhoods.contains(UUID()) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.julTerracotta)
                    }
                    .padding(Spacing.md)
                    .background(Color.julCardBackground)
                    .cornerRadius(Radius.md)
                    .onTapGesture {
                        // Toggle selection
                    }
                }
                
                JulesButton(title: "Continue", style: .primary) {
                    onContinue()
                }
                .padding(.horizontal, Spacing.lg)
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}

struct JulesIntroView: View {
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            Text("Meet Jules")
                .font(.julHeadline1())
                .foregroundColor(.julTextPrimary)
            
            Text("Your AI dating assistant is ready to help you find meaningful connections.")
                .font(.julBodyLarge())
                .foregroundColor(.julTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
            
            Spacer()
            
            JulesButton(title: "Start Matching", style: .primary) {
                onComplete()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xl)
        }
    }
}

