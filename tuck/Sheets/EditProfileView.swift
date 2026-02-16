import SwiftUI

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var userProfile: UserProfile
    
    @State private var displayName: String
    @State private var bio: String
    @State private var interests: String
    
    init(userProfile: Binding<UserProfile>) {
        self._userProfile = userProfile
        _displayName = State(initialValue: userProfile.wrappedValue.displayName)
        _bio = State(initialValue: userProfile.wrappedValue.bio)
        _interests = State(initialValue: userProfile.wrappedValue.interests.joined(separator: ", "))
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
                                Text((displayName.isEmpty ? userProfile.username : displayName).prefix(2).uppercased())
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    TextField("Display Name", text: $displayName)
                        .textContentType(.name)
                }
                
                Section("About") {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Interests (comma separated)", text: $interests)
                }
                
                Section {
                    Button("Change Profile Picture") {
                        // TODO: Implement photo picker
                    }
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
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveProfile() {
        userProfile.displayName = displayName
        userProfile.bio = bio
        userProfile.interests = interests.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        presentationMode.wrappedValue.dismiss()
    }
}
