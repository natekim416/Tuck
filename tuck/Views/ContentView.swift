import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BookmarkViewModel()
    @State private var selectedTab = 0
    @State private var showSmartSort = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(viewModel: viewModel)
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                DiscoverView(viewModel: viewModel)
                    .tabItem { Label("Discover", systemImage: "safari") }
                    .tag(1)

                SearchView(viewModel: viewModel)
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }
                    .tag(2)

                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
                    .tag(3)
            }
            .environmentObject(viewModel)
            .accentColor(.blue)

            // Floating Smart Sort button
            Button(action: { showSmartSort = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                    Text("Smart Sort")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.bottom, 60)
        }
        .sheet(isPresented: $showSmartSort) {
            SmartSortView()
        }
        .onAppear {
            viewModel.syncPendingBookmarks()
        }
    }
}
