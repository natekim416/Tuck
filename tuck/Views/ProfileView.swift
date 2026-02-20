import SwiftUI

struct ProfileView: View {
    @State private var showingLogoutAlert = false
    @State private var showingEditProfile = false
    @State private var showComingSoon = false
    @State private var userProfile = UserProfile(
        username: TuckServerAPI.shared.currentUser?.email.split(separator: "@").first.map(String.init) ?? "User",
        displayName: "",
        bio: "Bookmark enthusiast and knowledge curator",
        profileImageURL: nil,
        interests: ["Technology", "Design", "Productivity"]
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture
                        ZStack {
                            if let imageURL = userProfile.profileImageURL, !imageURL.isEmpty {
                                AsyncImage(url: URL(string: imageURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    profilePlaceholder
                                }
                            } else {
                                profilePlaceholder
                            }
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                        )
                        
                        // Name and Username
                        VStack(spacing: 4) {
                            Text(userProfile.displayName.isEmpty ? userProfile.username : userProfile.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("@\(userProfile.username)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if let email = TuckServerAPI.shared.currentUser?.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Bio
                        if !userProfile.bio.isEmpty {
                            Text(userProfile.bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        // Edit Profile Button
                        Button(action: { showingEditProfile = true }) {
                            Text("Edit Profile")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                    
                    // Stats
                    HStack(spacing: 40) {
                        StatView(value: userProfile.totalSaves, label: "Bookmarks")
                        StatView(value: userProfile.followers, label: "Followers")
                        StatView(value: userProfile.following, label: "Following")
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Interests
                    if !userProfile.interests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interests")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(userProfile.interests, id: \.self) { interest in
                                        Text(interest)
                                            .font(.subheadline)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.15))
                                            .foregroundColor(.blue)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Settings")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "bell.fill", title: "Notifications", color: .orange, action: { showComingSoon = true })
                            Divider().padding(.leading, 52)
                            SettingsRow(icon: "lock.fill", title: "Privacy", color: .blue, action: { showComingSoon = true })
                            Divider().padding(.leading, 52)
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .green, action: { showComingSoon = true })
                        }
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Logout Button
                    Button(action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Logout")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    performLogout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(userProfile: $userProfile)
            }
            .alert("Coming Soon", isPresented: $showComingSoon) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This feature is coming soon!")
            }
        }
    }
    
    private var profilePlaceholder: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text(userProfile.username.prefix(2).uppercased())
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func performLogout() {
        // Clear auth token and user data
        TuckServerAPI.shared.logout()
        
        // Post notification to refresh the app state
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
        
        // Exit the app or return to auth screen
        // The BookmarkApp will automatically show AuthView when isLoggedIn becomes false
    }
}

struct StatView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 28)

                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
    }
}
