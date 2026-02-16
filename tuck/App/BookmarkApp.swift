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
                        
                        // Listen for logout notifications
                        NotificationCenter.default.addObserver(
                            forName: NSNotification.Name("UserDidLogout"),
                            object: nil,
                            queue: .main
                        ) { _ in
                            isAuthenticated = false
                        }
                    }
            } else {
                AuthView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
