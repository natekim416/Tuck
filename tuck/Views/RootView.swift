import SwiftUI

struct RootView: View {
    @StateObject private var auth = AuthStore()

    var body: some View {
        Group {
            if auth.isRestoringSession {
                ProgressView()
            } else if auth.user == nil {
                LoginView()
            } else {
                ContentView() 
            }
        }
        .environmentObject(auth)
    }
}
