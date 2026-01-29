import SwiftUI

@main
struct BookmarkApp: App {
    @State private var isAuthenticated = TuckServerAPI.shared.isLoggedIn
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                RootView()
                    .onAppear {
                        // Re-check authentication when app appears
                        isAuthenticated = TuckServerAPI.shared.isLoggedIn
                    }
            } else {
                AuthView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
