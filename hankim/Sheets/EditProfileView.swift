import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    var profile: UserProfile
    var onSave: (UserProfile) -> Void
    
    @State private var displayName: String
    @State private var bio: String
    @State private var interests: String
    
    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        self.profile = profile
        self.onSave = onSave
        _displayName = State(initialValue: profile.displayName)
        _bio = State(initialValue: profile.bio)
        _interests = State(initialValue: profile.interests.joined(separator: ", "))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    HStack {
                        Spacer()
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(String(displayName.prefix(1)))
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    TextField("Display Name", text: $displayName)
                }
                
                Section("About") {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Interests (comma separated)", text: $interests)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
        }
    }
    
    private func saveProfile() {
        var updatedProfile = profile
        updatedProfile.displayName = displayName
        updatedProfile.bio = bio
        updatedProfile.interests = interests.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        onSave(updatedProfile)
        presentationMode.wrappedValue.dismiss()
    }
}
