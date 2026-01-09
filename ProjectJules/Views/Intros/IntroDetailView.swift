//
//  IntroDetailView.swift
//  ProjectJules
//
//  Intro detail with spark exchange and scheduling
//

import SwiftUI

struct IntroDetailView: View {
    let intro: Intro
    @State private var showSparkExchange = false
    @State private var showScheduling = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Intro message
                JulesCard {
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Jules says:")
                            .font(.julLabel())
                            .foregroundColor(.julTerracotta)
                        
                        Text(intro.julesMessage)
                            .font(.julBody())
                            .foregroundColor(.julTextPrimary)
                    }
                }
                .padding(.horizontal, Spacing.md)
                
                // Match info placeholder
                VStack(spacing: Spacing.md) {
                    Circle()
                        .fill(Color.julCream)
                        .frame(width: 100, height: 100)
                    
                    Text("Match Name")
                        .font(.julHeadline3())
                        .foregroundColor(.julTextPrimary)
                }
                .padding(.vertical, Spacing.lg)
                
                // Spark Exchange
                if !showSparkExchange {
                    JulesButton(title: "Send a Spark", style: .primary) {
                        showSparkExchange = true
                    }
                    .padding(.horizontal, Spacing.md)
                } else {
                    SparkExchangeView(onComplete: {
                        showScheduling = true
                    })
                    .padding(.horizontal, Spacing.md)
                }
                
                // Scheduling
                if showScheduling {
                    SchedulingView()
                        .padding(.horizontal, Spacing.md)
                }
            }
            .padding(.vertical, Spacing.md)
        }
        .navigationTitle("Introduction")
    }
}

struct SparkExchangeView: View {
    let onComplete: () -> Void
    @State private var selectedSpark: SparkExchange.SparkType? = nil
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Send a Spark")
                .font(.julHeadline3())
                .foregroundColor(.julTextPrimary)
            
            Text("Let them know you're interested")
                .font(.julBodySmall())
                .foregroundColor(.julTextSecondary)
            
            HStack(spacing: Spacing.md) {
                Button(action: { selectedSpark = .like }) {
                    VStack {
                        Image(systemName: "heart")
                            .font(.title)
                        Text("Like")
                            .font(.julLabel())
                    }
                    .foregroundColor(selectedSpark == .like ? .julTerracotta : .julTextSecondary)
                    .padding(Spacing.md)
                    .background(selectedSpark == .like ? Color.julCream : Color.clear)
                    .cornerRadius(Radius.md)
                }
                
                Button(action: { selectedSpark = .superLike }) {
                    VStack {
                        Image(systemName: "star.fill")
                            .font(.title)
                        Text("Super Like")
                            .font(.julLabel())
                    }
                    .foregroundColor(selectedSpark == .superLike ? .julTerracotta : .julTextSecondary)
                    .padding(Spacing.md)
                    .background(selectedSpark == .superLike ? Color.julCream : Color.clear)
                    .cornerRadius(Radius.md)
                }
            }
            
            if selectedSpark != nil {
                JulesButton(title: "Send", style: .primary) {
                    onComplete()
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.julCardBackground)
        .cornerRadius(Radius.lg)
    }
}

struct SchedulingView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedVenue: Venue? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Schedule a Date")
                .font(.julHeadline3())
                .foregroundColor(.julTextPrimary)
            
            DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .font(.julBody())
            
            Text("Suggested Venues")
                .font(.julLabel())
                .foregroundColor(.julTextPrimary)
            
            // Venue list placeholder
            ForEach(["Coffee Shop", "Art Gallery", "Restaurant"], id: \.self) { venueName in
                HStack {
                    Text(venueName)
                        .font(.julBody())
                        .foregroundColor(.julTextPrimary)
                    Spacer()
                    Image(systemName: selectedVenue?.name == venueName ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.julTerracotta)
                }
                .padding(Spacing.md)
                .background(Color.julCream)
                .cornerRadius(Radius.md)
                .onTapGesture {
                    // Select venue
                }
            }
            
            JulesButton(title: "Confirm Date", style: .primary) {
                // Confirm
            }
        }
        .padding(Spacing.lg)
        .background(Color.julCardBackground)
        .cornerRadius(Radius.lg)
    }
}

