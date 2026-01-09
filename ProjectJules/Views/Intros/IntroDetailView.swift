//
//  IntroDetailView.swift
//  ProjectJules
//
//  Intro Detail - Spark Exchange & Date Coordination
//

import SwiftUI

// MARK: - Intro Detail View
struct IntroDetailView: View {
    @StateObject private var viewModel: IntroDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(intro: IntroListItem) {
        _viewModel = StateObject(wrappedValue: IntroDetailViewModel(intro: intro))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Content based on intro status
                ScrollView {
                    VStack(spacing: JulesSpacing.lg) {
                        // Match header
                        MatchHeaderCard(
                            name: viewModel.matchName,
                            photoURL: viewModel.matchPhotoURL,
                            status: viewModel.intro.status,
                            onViewProfile: { viewModel.showFullProfile = true }
                        )

                        // Status-specific content
                        switch viewModel.intro.status {
                        case .sparkExchange:
                            SparkExchangeSection(viewModel: viewModel)

                        case .scheduling:
                            SchedulingSection(viewModel: viewModel)

                        case .scheduled:
                            ScheduledDateSection(viewModel: viewModel)

                        case .completed:
                            CompletedDateSection(viewModel: viewModel)

                        case .cancelled:
                            CancelledSection()
                        }
                    }
                    .padding(.horizontal, JulesSpacing.screen)
                    .padding(.vertical, JulesSpacing.md)
                }
                .background(Color.julCream)
            }
            .navigationTitle(viewModel.matchName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.julWarmBlack)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.showReportSheet = true }) {
                            Label("Report", systemImage: "exclamationmark.triangle")
                        }
                        Button(role: .destructive, action: { viewModel.showUnmatchAlert = true }) {
                            Label("Unmatch", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.julWarmBlack)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showFullProfile) {
                MatchProfileView(matchId: viewModel.intro.id)
            }
            .alert("Unmatch?", isPresented: $viewModel.showUnmatchAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Unmatch", role: .destructive) {
                    Task { await viewModel.unmatch() }
                }
            } message: {
                Text("This will end your intro with \(viewModel.matchName). This cannot be undone.")
            }
        }
    }
}

// MARK: - Match Header Card
struct MatchHeaderCard: View {
    let name: String
    let photoURL: String
    let status: IntroStatus
    let onViewProfile: () -> Void

    var body: some View {
        HStack(spacing: JulesSpacing.md) {
            // Photo
            AsyncImage(url: URL(string: photoURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.julInputBackground)
            }
            .frame(width: 72, height: 72)
            .clipShape(Circle())

            // Info
            VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                Text(name)
                    .font(.julTitle2)
                    .foregroundColor(.julWarmBlack)

                StatusBadge(status: status)
            }

            Spacer()

            // View Profile Button
            Button(action: onViewProfile) {
                Text("View Profile")
                    .font(.julBodySmall)
                    .foregroundColor(.julTerracotta)
            }
        }
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
        .julesShadow(.card)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: IntroStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(statusText)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)
        }
    }

    private var statusColor: Color {
        switch status {
        case .sparkExchange: return .julTerracotta
        case .scheduling: return .julSage
        case .scheduled: return .julSage
        case .completed: return .julWarmGray
        case .cancelled: return .julMutedRed
        }
    }

    private var statusText: String {
        switch status {
        case .sparkExchange: return "Spark Exchange"
        case .scheduling: return "Scheduling"
        case .scheduled: return "Date Scheduled"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

// MARK: - Spark Exchange Section
struct SparkExchangeSection: View {
    @ObservedObject var viewModel: IntroDetailViewModel

    var body: some View {
        VStack(spacing: JulesSpacing.lg) {
            // Jules intro message
            JulesCard {
                VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                    HStack(spacing: JulesSpacing.sm) {
                        JulesAvatar(size: 32)
                        Text("Jules")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)
                    }

                    Text("Before you two meet, let's get to know each other a bit! Answer the prompts below to share with \(viewModel.matchName).")
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                        .lineSpacing(3)
                }
            }

            // Spark prompts
            VStack(spacing: JulesSpacing.md) {
                ForEach(viewModel.sparkPrompts) { prompt in
                    SparkPromptCard(
                        prompt: prompt,
                        myResponse: viewModel.myResponses[prompt.id],
                        theirResponse: viewModel.theirResponses[prompt.id],
                        matchName: viewModel.matchName,
                        onRespond: { viewModel.selectedPrompt = prompt }
                    )
                }
            }

            // Progress indicator
            SparkProgressIndicator(
                completed: viewModel.myResponses.count,
                total: viewModel.sparkPrompts.count
            )

            // Continue to scheduling (when both complete)
            if viewModel.sparkExchangeComplete {
                JulesButton(title: "Ready to Schedule", style: .primary) {
                    Task { await viewModel.moveToScheduling() }
                }
            }
        }
        .sheet(item: $viewModel.selectedPrompt) { prompt in
            SparkResponseSheet(
                prompt: prompt,
                onSubmit: { response in
                    Task { await viewModel.submitSparkResponse(promptId: prompt.id, response: response) }
                }
            )
        }
    }
}

// MARK: - Spark Prompt Card
struct SparkPromptCard: View {
    let prompt: SparkPrompt
    let myResponse: String?
    let theirResponse: String?
    let matchName: String
    let onRespond: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.md) {
            // Prompt question
            Text(prompt.promptText)
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            // My response (or respond button)
            if let response = myResponse {
                ResponseBubble(
                    label: "You",
                    response: response,
                    isMe: true
                )
            } else {
                Button(action: onRespond) {
                    HStack {
                        Text("Share your answer")
                            .font(.julBody)
                            .foregroundColor(.julTerracotta)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.julTerracotta)
                    }
                    .padding(JulesSpacing.md)
                    .background(Color.julTerracotta.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
                }
            }

            // Their response (if available)
            if let response = theirResponse {
                ResponseBubble(
                    label: matchName,
                    response: response,
                    isMe: false
                )
            } else if myResponse != nil {
                HStack(spacing: JulesSpacing.xs) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Waiting for \(matchName)'s response...")
                        .font(.julCaption)
                        .foregroundColor(.julWarmGray)
                }
                .padding(.top, JulesSpacing.xs)
            }
        }
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

// MARK: - Response Bubble
struct ResponseBubble: View {
    let label: String
    let response: String
    let isMe: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            Text(label)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            Text(response)
                .font(.julBody)
                .foregroundColor(isMe ? .white : .julWarmBlack)
                .padding(JulesSpacing.sm)
                .background(isMe ? Color.julWarmBlack : Color.julInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
        }
    }
}

// MARK: - Spark Progress Indicator
struct SparkProgressIndicator: View {
    let completed: Int
    let total: Int

    var body: some View {
        VStack(spacing: JulesSpacing.sm) {
            HStack(spacing: JulesSpacing.xs) {
                ForEach(0..<total, id: \.self) { index in
                    Circle()
                        .fill(index < completed ? Color.julTerracotta : Color.julDivider)
                        .frame(width: 8, height: 8)
                }
            }

            Text("\(completed) of \(total) prompts answered")
                .font(.julCaption)
                .foregroundColor(.julWarmGray)
        }
    }
}

// MARK: - Spark Response Sheet
struct SparkResponseSheet: View {
    let prompt: SparkPrompt
    let onSubmit: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var responseText = ""
    @State private var isRecordingVoice = false

    var body: some View {
        NavigationStack {
            VStack(spacing: JulesSpacing.lg) {
                // Prompt
                VStack(spacing: JulesSpacing.sm) {
                    Text(prompt.promptText)
                        .font(.julTitle2)
                        .foregroundColor(.julWarmBlack)
                        .multilineTextAlignment(.center)

                    if prompt.allowVoiceNote {
                        Text("Text or voice note")
                            .font(.julCaption)
                            .foregroundColor(.julWarmGray)
                    }
                }
                .padding(.top, JulesSpacing.xl)

                Spacer()

                // Text input
                JulesTextArea(
                    placeholder: "Share your thoughts...",
                    text: $responseText,
                    characterLimit: 300
                )

                // Voice note option
                if prompt.allowVoiceNote {
                    HStack {
                        Text("or")
                            .font(.julCaption)
                            .foregroundColor(.julWarmGray)
                    }

                    Button(action: { isRecordingVoice = true }) {
                        HStack(spacing: JulesSpacing.sm) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 18))
                            Text("Record voice note")
                                .font(.julBody)
                        }
                        .foregroundColor(.julTerracotta)
                        .padding(JulesSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(Color.julTerracotta.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
                    }
                }

                Spacer()

                // Submit
                JulesButton(
                    title: "Share",
                    style: .primary,
                    isDisabled: responseText.trimmingCharacters(in: .whitespaces).isEmpty
                ) {
                    onSubmit(responseText)
                    dismiss()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
            .background(Color.julCream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.julWarmGray)
                }
            }
        }
    }
}

// MARK: - Scheduling Section
struct SchedulingSection: View {
    @ObservedObject var viewModel: IntroDetailViewModel

    var body: some View {
        VStack(spacing: JulesSpacing.lg) {
            // Jules message
            JulesCard {
                VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                    HStack(spacing: JulesSpacing.sm) {
                        JulesAvatar(size: 32)
                        Text("Jules")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)
                    }

                    Text("Great spark exchange! Now let's find a time that works for both of you. Select your availability for the next two weeks.")
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                        .lineSpacing(3)
                }
            }

            // Availability selector
            AvailabilitySelector(
                selectedSlots: $viewModel.selectedTimeSlots,
                matchAvailability: viewModel.matchAvailability
            )

            // Confirm availability
            JulesButton(
                title: "Confirm Availability",
                style: .primary,
                isDisabled: viewModel.selectedTimeSlots.isEmpty
            ) {
                Task { await viewModel.submitAvailability() }
            }
        }
    }
}

// MARK: - Availability Selector
struct AvailabilitySelector: View {
    @Binding var selectedSlots: Set<String>
    let matchAvailability: [String]

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d"
        return df
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.md) {
            Text("Select times you're free")
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            // Next 14 days
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: JulesSpacing.sm) {
                    ForEach(0..<14, id: \.self) { dayOffset in
                        let date = calendar.date(byAdding: .day, value: dayOffset, to: Date())!
                        DayAvailabilityColumn(
                            date: date,
                            selectedSlots: $selectedSlots,
                            matchHasAvailability: matchAvailability.contains(where: { $0.starts(with: dateFormatter.string(from: date)) })
                        )
                    }
                }
            }

            // Legend
            HStack(spacing: JulesSpacing.md) {
                LegendItem(color: .julTerracotta, label: "Your selection")
                LegendItem(color: .julSage, label: "Match overlap")
            }
            .padding(.top, JulesSpacing.sm)
        }
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

struct DayAvailabilityColumn: View {
    let date: Date
    @Binding var selectedSlots: Set<String>
    let matchHasAvailability: Bool

    private let timeSlots = ["Morning", "Afternoon", "Evening"]
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE\nMMM d"
        return df
    }()

    var body: some View {
        VStack(spacing: JulesSpacing.xs) {
            // Day header
            Text(dateFormatter.string(from: date))
                .font(.julCaption)
                .foregroundColor(.julWarmGray)
                .multilineTextAlignment(.center)
                .frame(width: 60)

            // Time slots
            ForEach(timeSlots, id: \.self) { slot in
                let slotId = "\(date.timeIntervalSince1970)-\(slot)"
                TimeSlotButton(
                    slot: slot,
                    isSelected: selectedSlots.contains(slotId),
                    hasMatchOverlap: matchHasAvailability
                ) {
                    if selectedSlots.contains(slotId) {
                        selectedSlots.remove(slotId)
                    } else {
                        selectedSlots.insert(slotId)
                    }
                }
            }
        }
    }
}

struct TimeSlotButton: View {
    let slot: String
    let isSelected: Bool
    let hasMatchOverlap: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(slot.prefix(3))
                .font(.julCaption)
                .foregroundColor(isSelected ? .white : .julWarmGray)
                .frame(width: 60, height: 32)
                .background(
                    isSelected
                        ? (hasMatchOverlap ? Color.julSage : Color.julTerracotta)
                        : Color.julInputBackground
                )
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)
        }
    }
}

// MARK: - Scheduled Date Section
struct ScheduledDateSection: View {
    @ObservedObject var viewModel: IntroDetailViewModel

    var body: some View {
        VStack(spacing: JulesSpacing.lg) {
            // Date confirmed card
            VStack(spacing: JulesSpacing.md) {
                Image(systemName: "calendar.badge.checkmark")
                    .font(.system(size: 48))
                    .foregroundColor(.julSage)

                Text("Date Scheduled!")
                    .font(.julTitle2)
                    .foregroundColor(.julWarmBlack)

                // Date details
                VStack(spacing: JulesSpacing.sm) {
                    DateDetailRow(icon: "calendar", text: viewModel.scheduledDateString)
                    DateDetailRow(icon: "clock", text: viewModel.scheduledTimeString)
                    DateDetailRow(icon: "mappin", text: viewModel.venueName)
                }
                .padding(JulesSpacing.md)
                .background(Color.julInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
            }
            .padding(JulesSpacing.lg)
            .background(Color.julCard)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))

            // Venue card
            if let venue = viewModel.venue {
                VenueCard(venue: venue)
            }

            // Reschedule option
            JulesButton(title: "Need to Reschedule?", style: .secondary) {
                viewModel.showRescheduleSheet = true
            }
        }
    }
}

struct DateDetailRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: JulesSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.julTerracotta)
                .frame(width: 24)

            Text(text)
                .font(.julBody)
                .foregroundColor(.julWarmBlack)

            Spacer()
        }
    }
}

// MARK: - Venue Card
struct VenueCard: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.md) {
            // Venue photo
            AsyncImage(url: URL(string: venue.photoUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.julInputBackground)
            }
            .frame(height: 160)
            .clipShape(RoundedCorner(radius: JulesRadius.medium, corners: [.topLeft, .topRight]))

            VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                Text(venue.name)
                    .font(.julTitle3)
                    .foregroundColor(.julWarmBlack)

                Text(venue.address)
                    .font(.julBody)
                    .foregroundColor(.julWarmGray)

                // Tags
                HStack(spacing: JulesSpacing.xs) {
                    JulesTag(text: venue.venueType.rawValue.capitalized)
                    JulesTag(text: venue.priceRange.displayString)
                    JulesTag(text: venue.vibe.rawValue.capitalized)
                }

                // Directions button
                Button(action: { openMaps(for: venue) }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond")
                            .font(.system(size: 14))
                        Text("Get Directions")
                            .font(.julBody)
                    }
                    .foregroundColor(.julTerracotta)
                }
            }
            .padding(.horizontal, JulesSpacing.md)
            .padding(.bottom, JulesSpacing.md)
        }
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
        .julesShadow(.card)
    }

    private func openMaps(for venue: Venue) {
        let urlString = "maps://?address=\(venue.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Completed Date Section
struct CompletedDateSection: View {
    @ObservedObject var viewModel: IntroDetailViewModel

    var body: some View {
        VStack(spacing: JulesSpacing.lg) {
            // Feedback request
            JulesCard {
                VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                    HStack(spacing: JulesSpacing.sm) {
                        JulesAvatar(size: 32)
                        Text("Jules")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)
                    }

                    Text("How did it go with \(viewModel.matchName)? Your feedback helps me find even better matches for you!")
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                        .lineSpacing(3)
                }
            }

            // Rating buttons
            if !viewModel.hasSubmittedFeedback {
                VStack(spacing: JulesSpacing.md) {
                    Text("Would you see them again?")
                        .font(.julTitle3)
                        .foregroundColor(.julWarmBlack)

                    HStack(spacing: JulesSpacing.md) {
                        FeedbackButton(
                            emoji: "sparkles",
                            label: "Definitely!",
                            isSelected: viewModel.selectedRating == .excellent
                        ) {
                            viewModel.selectedRating = .excellent
                        }

                        FeedbackButton(
                            emoji: "hand.thumbsup",
                            label: "Maybe",
                            isSelected: viewModel.selectedRating == .good
                        ) {
                            viewModel.selectedRating = .good
                        }

                        FeedbackButton(
                            emoji: "face.smiling",
                            label: "Just friends",
                            isSelected: viewModel.selectedRating == .neutral
                        ) {
                            viewModel.selectedRating = .neutral
                        }

                        FeedbackButton(
                            emoji: "xmark",
                            label: "No",
                            isSelected: viewModel.selectedRating == .poor
                        ) {
                            viewModel.selectedRating = .poor
                        }
                    }

                    JulesButton(
                        title: "Submit Feedback",
                        style: .primary,
                        isDisabled: viewModel.selectedRating == nil
                    ) {
                        Task { await viewModel.submitFeedback() }
                    }
                }
                .padding(JulesSpacing.lg)
                .background(Color.julCard)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
            } else {
                // Thank you message
                VStack(spacing: JulesSpacing.md) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.julTerracotta)

                    Text("Thanks for the feedback!")
                        .font(.julTitle3)
                        .foregroundColor(.julWarmBlack)

                    Text("This helps Jules learn your preferences and find better matches.")
                        .font(.julBody)
                        .foregroundColor(.julWarmGray)
                        .multilineTextAlignment(.center)
                }
                .padding(JulesSpacing.lg)
                .background(Color.julCard)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
            }
        }
    }
}

struct FeedbackButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: JulesSpacing.xs) {
                Image(systemName: emoji)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .julTerracotta : .julWarmGray)

                Text(label)
                    .font(.julCaption)
                    .foregroundColor(isSelected ? .julTerracotta : .julWarmGray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, JulesSpacing.sm)
            .background(isSelected ? Color.julTerracotta.opacity(0.1) : Color.julInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.small)
                    .stroke(isSelected ? Color.julTerracotta : .clear, lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Cancelled Section
struct CancelledSection: View {
    var body: some View {
        VStack(spacing: JulesSpacing.md) {
            Image(systemName: "xmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.julWarmGray)

            Text("This intro has ended")
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            Text("Don't worry, Jules is still looking for great matches for you!")
                .font(.julBody)
                .foregroundColor(.julWarmGray)
                .multilineTextAlignment(.center)
        }
        .padding(JulesSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

// MARK: - View Model
@MainActor
class IntroDetailViewModel: ObservableObject {
    let intro: IntroListItem

    @Published var matchName: String = ""
    @Published var matchPhotoURL: String = ""
    @Published var sparkPrompts: [SparkPrompt] = []
    @Published var myResponses: [String: String] = [:]
    @Published var theirResponses: [String: String] = [:]
    @Published var selectedPrompt: SparkPrompt?
    @Published var selectedTimeSlots: Set<String> = []
    @Published var matchAvailability: [String] = []
    @Published var venue: Venue?
    @Published var selectedRating: DateRating?
    @Published var hasSubmittedFeedback = false

    @Published var showFullProfile = false
    @Published var showReportSheet = false
    @Published var showUnmatchAlert = false
    @Published var showRescheduleSheet = false

    var sparkExchangeComplete: Bool {
        myResponses.count == sparkPrompts.count && theirResponses.count == sparkPrompts.count
    }

    var scheduledDateString: String {
        // TODO: Get from actual data
        "Saturday, January 15"
    }

    var scheduledTimeString: String {
        "7:00 PM"
    }

    var venueName: String {
        venue?.name ?? "TBD"
    }

    init(intro: IntroListItem) {
        self.intro = intro
        self.matchName = intro.names.components(separatedBy: " x ").first ?? intro.names
        self.matchPhotoURL = intro.photoURL

        // Load mock spark prompts
        loadSparkPrompts()
    }

    private func loadSparkPrompts() {
        sparkPrompts = [
            SparkPrompt(
                id: "1",
                category: .icebreaker,
                promptText: "What's something you're weirdly passionate about?",
                allowVoiceNote: true
            ),
            SparkPrompt(
                id: "2",
                category: .values,
                promptText: "What does a perfect Sunday look like for you?",
                allowVoiceNote: true
            ),
            SparkPrompt(
                id: "3",
                category: .lifestyle,
                promptText: "What's your go-to comfort food?",
                allowVoiceNote: false
            )
        ]
    }

    func submitSparkResponse(promptId: String, response: String) async {
        myResponses[promptId] = response
        // TODO: Send to backend
    }

    func moveToScheduling() async {
        // TODO: Update intro status
    }

    func submitAvailability() async {
        // TODO: Send availability to backend
    }

    func submitFeedback() async {
        hasSubmittedFeedback = true
        // TODO: Send feedback to backend
    }

    func unmatch() async {
        // TODO: Unmatch via backend
    }
}

// MARK: - Preview
#Preview {
    IntroDetailView(
        intro: IntroListItem(
            id: "1",
            names: "Sarah x You",
            photoURL: "https://picsum.photos/200",
            preview: "Spark Exchange in progress",
            timestamp: "Today",
            status: .sparkExchange
        )
    )
}
