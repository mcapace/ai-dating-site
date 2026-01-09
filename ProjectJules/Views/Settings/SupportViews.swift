//
//  SupportViews.swift
//  ProjectJules
//
//  Support & Info Views
//

import SwiftUI

// MARK: - Safety Tips View
struct SafetyTipsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.julSage)

                        Text("Your Safety Matters")
                            .font(.julTitle1)
                            .foregroundColor(.julWarmBlack)

                        Text("We want you to have great dates. Here are some tips to stay safe.")
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }

                    // Tips
                    VStack(spacing: JulesSpacing.md) {
                        SafetyTipCard(
                            number: 1,
                            title: "Meet in Public",
                            description: "Always meet your date in a public place for the first few times. Coffee shops, restaurants, and bars are great options."
                        )

                        SafetyTipCard(
                            number: 2,
                            title: "Tell a Friend",
                            description: "Let someone know where you're going and who you're meeting. Share your live location if you feel comfortable."
                        )

                        SafetyTipCard(
                            number: 3,
                            title: "Trust Your Gut",
                            description: "If something feels off, it probably is. Don't feel obligated to stay. Your comfort comes first."
                        )

                        SafetyTipCard(
                            number: 4,
                            title: "Arrange Your Own Transport",
                            description: "Don't rely on your date for a ride. Have your own way to get there and back."
                        )

                        SafetyTipCard(
                            number: 5,
                            title: "Keep Personal Info Private",
                            description: "Don't share your home address, workplace, or financial information until you've built trust."
                        )

                        SafetyTipCard(
                            number: 6,
                            title: "Video Chat First",
                            description: "Consider a video call before meeting in person. It helps verify who you're talking to."
                        )
                    }

                    // Emergency Resources
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("Need Help?")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)

                        Link(destination: URL(string: "tel:911")!) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.julMutedRed)
                                Text("Emergency: 911")
                                    .font(.julBody)
                                    .foregroundColor(.julWarmBlack)
                                Spacer()
                            }
                            .padding(JulesSpacing.md)
                            .background(Color.julCard)
                            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
                        }

                        Link(destination: URL(string: "https://www.rainn.org")!) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.julTerracotta)
                                Text("RAINN Support Hotline")
                                    .font(.julBody)
                                    .foregroundColor(.julWarmBlack)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.julWarmGray)
                            }
                            .padding(JulesSpacing.md)
                            .background(Color.julCard)
                            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
                        }
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("Safety Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.julTerracotta)
                }
            }
        }
    }
}

struct SafetyTipCard: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: JulesSpacing.md) {
            // Number badge
            Text("\(number)")
                .font(.julTitle3)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color.julSage)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                Text(title)
                    .font(.julTitle3)
                    .foregroundColor(.julWarmBlack)

                Text(description)
                    .font(.julBody)
                    .foregroundColor(.julWarmGray)
                    .lineSpacing(3)
            }
        }
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

// MARK: - Contact Support View
struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("How can we help?")
                            .font(.julTitle1)
                            .foregroundColor(.julWarmBlack)

                        Text("We typically respond within 24 hours.")
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }

                    // Quick Help
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("Quick Help")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)

                        QuickHelpButton(icon: "questionmark.circle", title: "FAQs", subtitle: "Common questions answered")
                        QuickHelpButton(icon: "person.badge.shield.checkmark", title: "Report a User", subtitle: "Safety concerns")
                        QuickHelpButton(icon: "creditcard", title: "Billing Issues", subtitle: "Subscription & payments")
                    }

                    Divider()
                        .background(Color.julDivider)

                    // Contact Form
                    VStack(alignment: .leading, spacing: JulesSpacing.md) {
                        Text("Send us a message")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)

                        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                            Text("Subject")
                                .font(.julCaption)
                                .foregroundColor(.julWarmGray)

                            JulesTextField(placeholder: "What's this about?", text: $subject)
                        }

                        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                            Text("Message")
                                .font(.julCaption)
                                .foregroundColor(.julWarmGray)

                            JulesTextArea(
                                placeholder: "Tell us more...",
                                text: $message,
                                minHeight: 150,
                                characterLimit: 1000
                            )
                        }

                        JulesButton(
                            title: "Send Message",
                            style: .primary,
                            isLoading: isSubmitting,
                            isDisabled: subject.isEmpty || message.isEmpty
                        ) {
                            submitMessage()
                        }
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.julWarmGray)
                }
            }
            .alert("Message Sent", isPresented: $showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("We'll get back to you within 24 hours.")
            }
        }
    }

    private func submitMessage() {
        isSubmitting = true
        // TODO: Send to support backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccessAlert = true
        }
    }
}

struct QuickHelpButton: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: JulesSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.julTerracotta)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)

                    Text(subtitle)
                        .font(.julCaption)
                        .foregroundColor(.julWarmGray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.julWarmGray)
            }
            .padding(JulesSpacing.md)
            .background(Color.julCard)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
        }
    }
}

// MARK: - Terms & Privacy View
struct TermsPrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("", selection: $selectedTab) {
                    Text("Terms").tag(0)
                    Text("Privacy").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)

                ScrollView {
                    VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                        if selectedTab == 0 {
                            TermsContent()
                        } else {
                            PrivacyContent()
                        }
                    }
                    .padding(.horizontal, JulesSpacing.screen)
                    .padding(.vertical, JulesSpacing.md)
                }
            }
            .background(Color.julCream)
            .navigationTitle(selectedTab == 0 ? "Terms of Service" : "Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.julTerracotta)
                }
            }
        }
    }
}

struct TermsContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.lg) {
            Text("Last updated: January 2026")
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            LegalSection(
                title: "1. Acceptance of Terms",
                content: "By accessing or using Jules, you agree to be bound by these Terms of Service. If you do not agree to all terms, you may not use our service."
            )

            LegalSection(
                title: "2. Eligibility",
                content: "You must be at least 18 years old to use Jules. By using our service, you represent that you are of legal age in your jurisdiction."
            )

            LegalSection(
                title: "3. User Conduct",
                content: "You agree to treat other users with respect, provide accurate information about yourself, and not engage in harassment, fraud, or illegal activities."
            )

            LegalSection(
                title: "4. Subscriptions & Payments",
                content: "Premium features require a subscription. Payments are processed through the App Store. Subscriptions auto-renew unless cancelled 24 hours before the end of the billing period."
            )

            LegalSection(
                title: "5. Content",
                content: "You retain ownership of content you post but grant Jules a license to use it for providing our service. We may remove content that violates our guidelines."
            )

            LegalSection(
                title: "6. Limitation of Liability",
                content: "Jules is not responsible for the actions of users. We provide a platform for connection but cannot guarantee the quality of matches or outcomes of dates."
            )
        }
    }
}

struct PrivacyContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.lg) {
            Text("Last updated: January 2026")
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            LegalSection(
                title: "Information We Collect",
                content: "We collect information you provide (profile data, photos, preferences), usage data (app interactions, matches), and device information for security and analytics."
            )

            LegalSection(
                title: "How We Use Your Information",
                content: "We use your data to provide matches, improve our AI matchmaking, communicate with you, and ensure safety. We never sell your personal data."
            )

            LegalSection(
                title: "AI & Your Data",
                content: "Jules uses AI to analyze your preferences and communication style to find better matches. Your conversations with Jules are used to personalize your experience."
            )

            LegalSection(
                title: "Data Sharing",
                content: "We share limited profile information with potential matches. We may share data with service providers (hosting, analytics) under strict privacy agreements."
            )

            LegalSection(
                title: "Your Rights",
                content: "You can access, update, or delete your data at any time through the app settings. You can also request a copy of your data."
            )

            LegalSection(
                title: "Data Security",
                content: "We use industry-standard encryption and security measures to protect your data. All data is stored on secure servers."
            )

            LegalSection(
                title: "Contact Us",
                content: "For privacy questions, contact us at privacy@projectjules.app"
            )
        }
    }
}

struct LegalSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            Text(title)
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            Text(content)
                .font(.julBody)
                .foregroundColor(.julWarmGray)
                .lineSpacing(4)
        }
    }
}

// MARK: - Previews
#Preview("Safety Tips") {
    SafetyTipsView()
}

#Preview("Contact Support") {
    ContactSupportView()
}

#Preview("Terms & Privacy") {
    TermsPrivacyView()
}
