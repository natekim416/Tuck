import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthStore
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var showingEditProfile = false
    @State private var showingLogoutConfirm = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProfileHeaderView(profile: viewModel.userProfile, onEdit: { showingEditProfile = true })

                    Divider().padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Public Folders")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.folders.filter { $0.isPublic }) { folder in
                                NavigationLink(destination: FolderDetailView(folder: folder, viewModel: viewModel)) {
                                    FolderCard(folder: folder)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        SettingsRow(icon: "bell", title: "Notifications", color: .orange)
                        SettingsRow(icon: "lock", title: "Privacy", color: .blue)
                        SettingsRow(icon: "gear", title: "Settings", color: .gray)
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .toolbar { 
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingLogoutConfirm = true
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .confirmationDialog("Log out?", isPresented: $showingLogoutConfirm) {
                Button("Log out", role: .destructive) {
                    auth.signOut()
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(profile: viewModel.userProfile) { updated in
                    viewModel.userProfile = updated
                }
            }
        }
    }
}


struct ProfileHeaderView: View {
    let profile: UserProfile
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple],
                                       startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(String(profile.username.prefix(1)))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                }
            }
            
            Text(profile.displayName)
                .font(.title2)
                .fontWeight(.bold)
            
            if !profile.bio.isEmpty {
                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack(spacing: 40) {
                VStack {
                    Text("\(profile.followers)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Followers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text("\(profile.following)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Following")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                VStack {
                    Text("\(profile.totalSaves)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Saves")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 30)
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}
