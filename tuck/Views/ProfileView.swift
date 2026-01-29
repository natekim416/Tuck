import SwiftUI

struct ProfileView: View {
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Your existing profile content...
                
                Section {
                    Button(role: .destructive, action: { showingLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Logout")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    TuckServerAPI.shared.logout()
                    // This will trigger the app to show AuthView
                    // You may need to use @AppStorage or NotificationCenter
                    // to notify BookmarkApp about the logout
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}
