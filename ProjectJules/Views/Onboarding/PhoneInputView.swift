//
//  PhoneInputView.swift
//  ProjectJules
//
//  Onboarding: Phone Input & Verification
//

import SwiftUI

// MARK: - Phone Input View
struct PhoneInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                JulesIconButton(icon: "arrow.left", size: 44, backgroundColor: .clear) {
                    viewModel.previousStep()
                }
                Spacer()
            }
            .padding(.horizontal, JulesSpacing.screen)

            Spacer()
                .frame(height: JulesSpacing.xl)

            // Content
            VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                    Text("What's your number?")
                        .font(.julTitle1)
                        .foregroundColor(.julWarmBlack)

                    Text("We'll text you a code to verify it's really you.")
                        .font(.julBody)
                        .foregroundColor(.julWarmGray)
                }

                JulesPhoneInput(
                    phoneNumber: $viewModel.phoneNumber,
                    isError: viewModel.error != nil,
                    errorMessage: viewModel.error
                )
            }
            .padding(.horizontal, JulesSpacing.screen)

            Spacer()

            // Continue Button
            VStack(spacing: JulesSpacing.md) {
                JulesButton(
                    title: "Send Code",
                    style: .primary,
                    isLoading: viewModel.isLoading,
                    isDisabled: !isValidPhone
                ) {
                    Task {
                        await viewModel.sendOTP()
                    }
                }

                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.julCaption)
                    .foregroundColor(.julWarmGray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
        }
    }

    private var isValidPhone: Bool {
        let digits = viewModel.phoneNumber.filter { $0.isNumber }
        return digits.count >= 10
    }
}

// MARK: - Verification View
struct VerificationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var canResend = false
    @State private var resendCountdown = 60

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                JulesIconButton(icon: "arrow.left", size: 44, backgroundColor: .clear) {
                    viewModel.previousStep()
                }
                Spacer()
            }
            .padding(.horizontal, JulesSpacing.screen)

            Spacer()
                .frame(height: JulesSpacing.xl)

            // Content
            VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                    Text("Enter the code")
                        .font(.julTitle1)
                        .foregroundColor(.julWarmBlack)

                    Text("Sent to \(viewModel.phoneNumber)")
                        .font(.julBody)
                        .foregroundColor(.julWarmGray)
                }

                JulesOTPInput(
                    code: $viewModel.verificationCode,
                    onComplete: { code in
                        Task {
                            await viewModel.verifyOTP()
                        }
                    }
                )

                // Resend button
                HStack {
                    Spacer()
                    if canResend {
                        JulesTextButton(title: "Resend code", color: .julTerracotta) {
                            Task {
                                await viewModel.sendOTP()
                                resetResendTimer()
                            }
                        }
                    } else {
                        Text("Resend code in \(resendCountdown)s")
                            .font(.julBodySmall)
                            .foregroundColor(.julWarmGray)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)

            Spacer()

            // Loading indicator or error
            if viewModel.isLoading {
                ProgressView()
                    .padding(.bottom, JulesSpacing.xl)
            }

            if let error = viewModel.error {
                Text(error)
                    .font(.julBodySmall)
                    .foregroundColor(.julMutedRed)
                    .padding(.horizontal, JulesSpacing.screen)
                    .padding(.bottom, JulesSpacing.xl)
            }
        }
        .onReceive(timer) { _ in
            if resendCountdown > 0 {
                resendCountdown -= 1
            } else {
                canResend = true
            }
        }
    }

    private func resetResendTimer() {
        canResend = false
        resendCountdown = 60
    }
}

// MARK: - Preview
#Preview("Phone Input") {
    PhoneInputView(viewModel: OnboardingViewModel())
        .background(Color.julCream)
}

#Preview("Verification") {
    let vm = OnboardingViewModel()
    vm.phoneNumber = "(555) 123-4567"
    return VerificationView(viewModel: vm)
        .background(Color.julCream)
}
