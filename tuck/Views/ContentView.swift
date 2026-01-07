import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookmarkViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            DiscoverView(viewModel: viewModel)
                .tabItem {
                    Label("Discover", systemImage: "safari")
                }
                .tag(1)
            
            SearchView(viewModel: viewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            viewModel.syncPendingBookmarks()
        }
    }
}
