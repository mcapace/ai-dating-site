//
//  MatchDetailView.swift
//  ProjectJules
//
//  Full match profile view
//

import SwiftUI

struct MatchDetailView: View {
    let match: Match
    @Environment(\.dismiss) var dismiss
    @State private var currentPhotoIndex = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Photo gallery
                TabView(selection: $currentPhotoIndex) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.julCream)
                            .frame(height: 400)
                            .overlay(
                                Text("Photo \(index + 1)")
                                    .font(.julBody())
                                    .foregroundColor(.julTextSecondary)
                            )
                    }
                }
                .tabViewStyle(.page)
                .frame(height: 400)
                
                // Profile info
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text(match.userName)
                        .font(.julHeadline2())
                        .foregroundColor(.julTextPrimary)
                    
                    if let bio = match.bio {
                        Text(bio)
                            .font(.julBody())
                            .foregroundColor(.julTextSecondary)
                    }
                    
                    // Interests
                    Text("Interests")
                        .font(.julLabel())
                        .foregroundColor(.julTextPrimary)
                    
                    FlowLayout(spacing: Spacing.sm) {
                        TagView(text: "Coffee")
                        TagView(text: "Art")
                        TagView(text: "Travel")
                    }
                    
                    // Action buttons
                    HStack(spacing: Spacing.md) {
                        JulesButton(title: "Pass", style: .outline) {
                            // Handle pass
                            dismiss()
                        }
                        
                        JulesButton(title: "Like", style: .primary) {
                            // Handle like
                        }
                        
                        JulesButton(title: "Super Like", style: .secondary) {
                            // Handle super like
                        }
                    }
                }
                .padding(Spacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

