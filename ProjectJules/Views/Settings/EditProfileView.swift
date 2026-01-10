//
//  EditProfileView.swift
//  ProjectJules
//
//  Profile Editing Screens
//

import SwiftUI
import PhotosUI

// MARK: - Edit Profile (My Info)
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: JulesSpacing.lg) {
                    // Photos Section
                    PhotosEditSection(
                        photos: $viewModel.photos,
                        onAddPhoto: { viewModel.showPhotoPicker = true },
                        onRemovePhoto: { index in viewModel.removePhoto(at: index) }
                    )

                    // Basic Info
                    SectionCard(title: "Basic Info") {
                        VStack(spacing: JulesSpacing.md) {
                            EditTextField(label: "First name", text: $viewModel.firstName)

                            EditFieldButton(label: "Birthday", value: viewModel.formattedBirthday) {
                                viewModel.showDatePicker = true
                            }

                            EditPicker(label: "Gender", selection: $viewModel.gender, options: Gender.allCases)
                        }
                    }

                    // More Details
                    SectionCard(title: "More About Me") {
                        VStack(spacing: JulesSpacing.md) {
                            EditPicker(label: "Height", selection: $viewModel.heightInches, options: Array(54...84)) { inches in
                                formatHeight(inches)
                            }

                            EditTextField(label: "Occupation", text: $viewModel.occupation)

                            EditToggle(label: "Have children", isOn: $viewModel.hasChildren)

                            EditPicker(label: "Want children", selection: $viewModel.wantsChildren, options: WantsChildren.allCases)

                            EditTextField(label: "Ethnicity", text: $viewModel.ethnicity)

                            EditTextField(label: "Religion", text: $viewModel.religion)
                        }
                    }

                    // Bio
                    SectionCard(title: "About Me") {
                        JulesTextArea(
                            placeholder: "Share a bit about yourself...",
                            text: $viewModel.bio,
                            characterLimit: 500
                        )
                    }
                }
                .padding(.horizontal, JulesSpacing.screen)
                .padding(.vertical, JulesSpacing.md)
            }
            .background(Color.julCream)
            .navigationTitle("My Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.julWarmGray)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            dismiss()
                        }
                    }
                    .font(.julButton)
                    .foregroundColor(.julTerracotta)
                    .disabled(!viewModel.hasChanges)
                }
            }
            .sheet(isPresented: $viewModel.showDatePicker) {
                DatePickerSheet(date: $viewModel.birthDate)
            }
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.selectedPhotoItem,
                matching: .images
            )
            .onChange(of: viewModel.selectedPhotoItem) { _, item in
                Task { await viewModel.handlePhotoSelection(item) }
            }
        }
    }

    private func formatHeight(_ inches: Int) -> String {
        let feet = inches / 12
        let remainingInches = inches % 12
        return "\(feet)'\(remainingInches)\""
    }
}

// MARK: - Photos Edit Section
struct PhotosEditSection: View {
    @Binding var photos: [EditablePhoto]
    let onAddPhoto: () -> Void
    let onRemovePhoto: (Int) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.sm) {
            Text("Photos")
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            Text("Add at least 2 photos")
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            LazyVGrid(columns: columns, spacing: JulesSpacing.sm) {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    PhotoEditSlot(
                        photo: photo,
                        index: index,
                        onRemove: { onRemovePhoto(index) }
                    )
                }

                // Add photo button (up to 6)
                if photos.count < 6 {
                    AddPhotoButton(action: onAddPhoto)
                }
            }
        }
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

struct PhotoEditSlot: View {
    let photo: EditablePhoto
    let index: Int
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
            } else if let url = photo.url {
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.julInputBackground)
                        .overlay(ProgressView())
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
            }

            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }
            .padding(4)

            // Primary badge
            if index == 0 {
                Text("Primary")
                    .font(.julCaption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.julTerracotta)
                    .clipShape(Capsule())
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .frame(height: 120)
    }
}

struct AddPhotoButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: JulesSpacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.julWarmGray)

                Text("Add")
                    .font(.julCaption)
                    .foregroundColor(.julWarmGray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.julInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: JulesRadius.small))
            .overlay(
                RoundedRectangle(cornerRadius: JulesRadius.small)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .foregroundColor(.julWarmGray)
            )
        }
    }
}

// MARK: - Section Card
struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.md) {
            Text(title)
                .font(.julTitle3)
                .foregroundColor(.julWarmBlack)

            content()
        }
        .padding(JulesSpacing.md)
        .background(Color.julCard)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.medium))
    }
}

// MARK: - Edit Field Components
struct EditTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            Text(label)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            JulesTextField(placeholder: label, text: $text)
        }
    }
}

struct EditFieldButton: View {
    let label: String
    let value: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            Text(label)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            Button(action: action) {
                HStack {
                    Text(value)
                        .font(.julBody)
                        .foregroundColor(.julWarmBlack)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.julWarmGray)
                }
                .padding(JulesSpacing.md)
                .background(Color.julInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
            }
        }
    }
}

struct EditPicker<T: Hashable>: View {
    let label: String
    @Binding var selection: T?
    let options: [T]
    var displayValue: ((T) -> String)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: JulesSpacing.xs) {
            Text(label)
                .font(.julCaption)
                .foregroundColor(.julWarmGray)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(displayString(for: option)) {
                        selection = option
                    }
                }
            } label: {
                HStack {
                    if let selected = selection {
                        Text(displayString(for: selected))
                            .font(.julBody)
                            .foregroundColor(.julWarmBlack)
                    } else {
                        Text("Select")
                            .font(.julBody)
                            .foregroundColor(.julWarmGray)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.julWarmGray)
                }
                .padding(JulesSpacing.md)
                .background(Color.julInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
            }
        }
    }

    private func displayString(for value: T) -> String {
        if let displayValue = displayValue {
            return displayValue(value)
        }
        if let displayable = value as? any RawRepresentable, let rawValue = displayable.rawValue as? String {
            return rawValue.capitalized
        }
        return String(describing: value)
    }
}

struct EditToggle: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(.julBody)
                .foregroundColor(.julWarmBlack)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.julTerracotta)
        }
        .padding(JulesSpacing.md)
        .background(Color.julInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: JulesRadius.input))
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var date: Date

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Birthday",
                    selection: $date,
                    in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                Spacer()
            }
            .padding()
            .navigationTitle("Birthday")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.julTerracotta)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Editable Photo Model
struct EditablePhoto: Identifiable {
    let id: String
    var url: String?
    var image: UIImage?
    var isNew: Bool = false
}

// MARK: - Edit Profile View Model
@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var photos: [EditablePhoto] = []
    @Published var firstName = ""
    @Published var birthDate = Date()
    @Published var gender: Gender? = nil
    @Published var heightInches: Int? = nil
    @Published var occupation = ""
    @Published var hasChildren = false
    @Published var wantsChildren: WantsChildren? = nil
    @Published var ethnicity = ""
    @Published var religion = ""
    @Published var bio = ""

    @Published var showPhotoPicker = false
    @Published var showDatePicker = false
    @Published var selectedPhotoItem: PhotosPickerItem?

    private var originalData: [String: Any] = [:]

    var hasChanges: Bool {
        // Check if any field has changed
        true // Simplified for now
    }

    var formattedBirthday: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }

    init() {
        loadProfile()
    }

    private func loadProfile() {
        // Load from AuthService
        if let profile = AuthService.shared.currentProfile {
            firstName = profile.firstName
            birthDate = profile.birthdate
            gender = profile.gender
            heightInches = profile.heightInches
            occupation = profile.occupation ?? ""
            hasChildren = profile.hasChildren ?? false
            wantsChildren = profile.wantsChildren
            ethnicity = profile.ethnicity ?? ""
            religion = profile.religion ?? ""
            bio = profile.bio ?? ""
        }

        // Load photos
        // TODO: Load from UserService
    }

    func handlePhotoSelection(_ item: PhotosPickerItem?) async {
        guard let item = item else { return }

        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            let newPhoto = EditablePhoto(id: UUID().uuidString, image: image, isNew: true)
            photos.append(newPhoto)
        }
    }

    func removePhoto(at index: Int) {
        guard index < photos.count else { return }
        photos.remove(at: index)
    }

    func save() async {
        // TODO: Save to UserService
    }
}

// MARK: - Preview
#Preview {
    EditProfileView()
}
