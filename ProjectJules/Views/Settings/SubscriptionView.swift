//
//  SubscriptionView.swift
//  ProjectJules
//
//  Subscription Management
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SubscriptionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: JulesSpacing.lg) {
                    // Current Plan
                    CurrentPlanCard(
                        tier: viewModel.currentTier,
                        renewalDate: viewModel.renewalDate
                    )

                    // Upgrade Options (if not premium)
                    if viewModel.currentTier == .free {
                        UpgradeSection(
                            onSelectPlan: { plan in
                                viewModel.selectedPlan = plan
                                viewModel.showPaymentSheet = true
                            }
                        )
                    }

                    // Premium Benefits
                    BenefitsSection()

                    // Manage Subscription
                    if viewModel.currentTier != .free {
                        ManageSubscriptionSection(
                            onCancel: { viewModel.showCancelAlert = true }
                        )
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("My Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.julWarmBlack)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showPaymentSheet) {
                PaymentSheet(
                    plan: viewModel.selectedPlan ?? .monthly,
                    onComplete: { success in
                        if success {
                            viewModel.handlePurchaseSuccess()
                        }
                    }
                )
            }
            .alert("Cancel Subscription?", isPresented: $viewModel.showCancelAlert) {
                Button("Keep Subscription", role: .cancel) { }
                Button("Cancel", role: .destructive) {
                    Task { await viewModel.cancelSubscription() }
                }
            } message: {
                Text("You'll lose access to premium features at the end of your billing period.")
            }
        }
    }
}

// MARK: - Current Plan Card
struct CurrentPlanCard: View {
    let tier: SubscriptionTier
    let renewalDate: Date?

    var body: some View {
        VStack(spacing: JulesSpacing.md) {
            // Plan Icon
            ZStack {
                Circle()
                    .fill(tier == .free ? Color.julInputBackground : LinearGradient.julPremiumGradient)
                    .frame(width: 64, height: 64)

                Image(systemName: tier == .free ? "person.fill" : "crown.fill")
                    .font(.system(size: 28))
                    .foregroundColor(tier == .free ? .julWarmGray : .white)
            }

            // Plan Name
            Text(tier.displayName)
                .font(.julTitle2)
                .foregroundColor(.julWarmBlack)

            // Status
            if tier == .free {
                Text("Upgrade to unlock premium features")
                    .font(.julBody)
                    .foregroundColor(.julWarmGray)
                    .multilineTextAlignment(.center)
            } else if let renewalDate = renewalDate {
                let formatter = DateFormatter()
                Text("Renews \(formatter.string(from: renewalDate))")
                    .font(.julBody)
                    .foregroundColor(.julWarmGray)
            }
        }
        .padding(JulesSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

// MARK: - Upgrade Section
struct UpgradeSection: View {
    let onSelectPlan: (SubscriptionPlan) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.md) {
            Text("Choose Your Plan")
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            // Monthly Plan
            PlanCard(
                plan: .monthly,
                isPopular: false,
                onSelect: { onSelectPlan(.monthly) }
            )

            // Annual Plan (Best Value)
            PlanCard(
                plan: .annual,
                isPopular: true,
                onSelect: { onSelectPlan(.annual) }
            )
        }
    }
}

enum SubscriptionPlan {
    case monthly
    case annual

    var price: String {
        switch self {
        case .monthly: return "$35"
        case .annual: return "$280"
        }
    }

    var period: String {
        switch self {
        case .monthly: return "/month"
        case .annual: return "/year"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "Save $140"
        }
    }

    var monthlyEquivalent: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "~$23/month"
        }
    }
}

struct PlanCard: View {
    let plan: SubscriptionPlan
    let isPopular: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Popular badge
                if isPopular {
                    Text("BEST VALUE")
                        .font(.julCaption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, JulesSpacing.md)
                        .padding(.vertical, JulesSpacing.xs)
                        .frame(maxWidth: .infinity)
                        .background(Color.julTerracotta)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan == .monthly ? "Monthly" : "Annual")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)

                        if let equivalent = plan.monthlyEquivalent {
                            Text(equivalent)
                                .font(.julCaption)
                                .foregroundColor(.julWarmGray)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(plan.price)
                                .font(.julTitle2)
                                .foregroundColor(.julWarmBlack)

                            Text(plan.period)
                                .font(.julCaption)
                                .foregroundColor(.julWarmGray)
                        }

                        if let savings = plan.savings {
                            Text(savings)
                                .font(.julCaption)
                                .foregroundColor(.julSage)
                                .fontWeight(.medium)
                        }
                    }
                }
                .padding(JulesSpacing.md)
            }
            .background(Color.julCard)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.medium)
                    .stroke(isPopular ? Color.julTerracotta : Color.julDivider, lineWidth: isPopular ? 2 : 1)
            )
        }
    }
}

// MARK: - Benefits Section
struct BenefitsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.md) {
            Text("Premium Benefits")
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            VStack(spacing: JulesSpacing.sm) {
                BenefitRow(icon: "bolt.fill", title: "Priority Matching", description: "Get pitched to matches first")
                BenefitRow(icon: "envelope.fill", title: "Unlimited Notes", description: "Send personalized notes to matches")
                BenefitRow(icon: "star.fill", title: "Standout Days", description: "Get featured once a week")
                BenefitRow(icon: "infinity", title: "Unlimited Dates", description: "No limit on monthly intros")
                BenefitRow(icon: "eye.fill", title: "See Who Likes You", description: "Know before Jules tells you")
            }
            .padding(JulesSpacing.md)
            .background(Color.julCard)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: JulesSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.julTerracotta)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.julBody)
                    .foregroundColor(.julWarmBlack)

                Text(description)
                    .font(.julCaption)
                    .foregroundColor(.julWarmGray)
            }

            Spacer()
        }
    }
}

// MARK: - Manage Subscription Section
struct ManageSubscriptionSection: View {
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: JulesSpacing.md) {
            Button(action: {
                // Open App Store subscription management
                if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Text("Manage in App Store")
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                        .foregroundColor(.julWarmGray)
                }
                .padding(JulesSpacing.md)
                .background(Color.julCard)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
            }

            Button(action: onCancel) {
                Text("Cancel Subscription")
                    .font(.julBody)
                    .foregroundColor(.julMutedRed)
            }
        }
    }
}

// MARK: - Payment Sheet
struct PaymentSheet: View {
    let plan: SubscriptionPlan
    let onComplete: (Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: JulesSpacing.xl) {
                Spacer()

                // Plan Summary
                VStack(spacing: JulesSpacing.md) {
                    Text("Jules Premium")
                        .font(.julTitle1)
                        .foregroundColor(.julWarmBlack)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(plan.price)
                            .font(.system(size: 48, weight: .semibold, design: .serif))
                            .foregroundColor(.julTerracotta)

                        Text(plan.period)
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }

                    if let savings = plan.savings {
                        Text(savings)
                            .font(.julBody)
                            .foregroundColor(.julSage)
                            .padding(.horizontal, JulesSpacing.md)
                            .padding(.vertical, JulesSpacing.xs)
                            .background(Color.julSage.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                // Purchase Button
                JulesButton(
                    title: "Subscribe Now",
                    style: .primary,
                    isLoading: isProcessing
                ) {
                    Task { await purchase() }
                }

                // Terms
                Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.")
                    .font(.julCaption)
                    .foregroundColor(.julWarmGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, JulesSpacing.lg)
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
            .background(Color.julCream)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.julWarmGray)
                    }
                }
            }
        }
    }

    private func purchase() async {
        isProcessing = true
        // TODO: Implement StoreKit purchase
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        isProcessing = false
        onComplete(true)
        dismiss()
    }
}

// MARK: - View Model
@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var currentTier: SubscriptionTier = .free
    @Published var renewalDate: Date?
    @Published var selectedPlan: SubscriptionPlan?
    @Published var showPaymentSheet = false
    @Published var showCancelAlert = false

    init() {
        loadSubscriptionStatus()
    }

    private func loadSubscriptionStatus() {
        // TODO: Check StoreKit subscription status
    }

    func handlePurchaseSuccess() {
        currentTier = .premium
        renewalDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
    }

    func cancelSubscription() async {
        // TODO: Handle cancellation
    }
}

// MARK: - Preview
#Preview {
    SubscriptionView()
}
