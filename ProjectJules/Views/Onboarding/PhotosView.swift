//
//  PhotosView.swift
//  ProjectJules
//
//  Onboarding: Photo Upload
//

import SwiftUI
import PhotosUI

struct PhotosView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingImagePicker = false

    let columns = [
        GridItem(.flexible(), spacing: JulesSpacing.xxs),
        GridItem(.flexible(), spacing: JulesSpacing.xxs),
        GridItem(.flexible(), spacing: JulesSpacing.xxs)
    ]

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

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: JulesSpacing.lg) {
                    // Title
                    VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                        Text("Add some photos")
                            .font(.julTitle1)
                            .foregroundColor(.julWarmBlack)

                        Text("You need at least 3. Show your face clearly in the first one - no sunglasses, no groups.")
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }

                    // Photo Grid
                    LazyVGrid(columns: columns, spacing: JulesSpacing.xxs) {
                        ForEach(0..<6, id: \.self) { index in
                            PhotoSlot(
                                image: index < viewModel.photos.count ? viewModel.photos[index] : nil,
                                index: index,
                                onAdd: {
                                    showingImagePicker = true
                                },
                                onRemove: {
                                    if index < viewModel.photos.count {
                                        viewModel.photos.remove(at: index)
                                    }
                                }
                            )
                        }
                    }

                    // Tips
                    VStack(alignment: .leading, spacing: JulesSpacing.sm) {
                        Text("Photo tips")
                            .font(.julTitle3)
                            .foregroundColor(.julWarmBlack)

                        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
                            TipRow(icon: "sun.max", text: "Use natural lighting")
                            TipRow(icon: "face.smiling", text: "Show a genuine smile")
                            TipRow(icon: "figure.stand", text: "Include a full body shot")
                            TipRow(icon: "heart", text: "Show your interests/hobbies")
                        }
                    }
                    .padding(JulesSpacing.md)
                    .background(Color.julCard)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.top, JulesSpacing.lg)
            }

            // Continue Button
            JulesButton(
                title: "Continue (\(viewModel.photos.count)/3 minimum)",
                style: .primary,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.photos.count < 3
            ) {
                Task {
                    await viewModel.uploadPhotos()
                }
            }
            .padding(.horizontal, JulesSpacing.screen)
            .padding(.bottom, JulesSpacing.xl)
        }
        .photosPicker(
            isPresented: $showingImagePicker,
            selection: $selectedItems,
            maxSelectionCount: 6 - viewModel.photos.count,
            matching: .images
        )
        .onChange(of: selectedItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            if viewModel.photos.count < 6 {
                                viewModel.photos.append(image)
                            }
                        }
                    }
                }
                selectedItems = []
            }
        }
    }
}

// MARK: - Photo Slot
struct PhotoSlot: View {
    let image: UIImage?
    let index: Int
    let onAdd: () -> Void
    let onRemove: () -> Void

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
                    .overlay(alignment: .topTrailing) {
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                        }
                        .padding(6)
                    }
                    .overlay(alignment: .bottomLeading) {
                        if index == 0 {
                            Text("Main")
                                .font(.julCaption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.julWarmBlack.opacity(0.7))
                                .clipShape(Capsule())
                                .padding(8)
                        }
                    }
            } else {
                Button(action: onAdd) {
                    RoundedRectangle(cornerRadius: JulesRadius.medium)
                        .strokeBorder(Color.julDivider, style: StrokeStyle(lineWidth: 2, dash: [8]))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.julWarmGray)
                        )
                }
            }
        }
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: JulesSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.julTerracotta)
                .frame(width: 20)

            Text(text)
                .font(.julBodySmall)
                .foregroundColor(.julWarmGray)
        }
    }
}

// MARK: - Preview
#Preview {
    PhotosView(viewModel: OnboardingViewModel())
        .background(Color.julCream)
}
