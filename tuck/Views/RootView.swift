import SwiftUI

struct RootView: View {
    @State private var selectedTab = 0
    @State private var showSmartSort = false
    @StateObject private var viewModel = BookmarkViewModel()

    
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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .overlay(
            VStack {
                Spacer()
                Button(action: { showSmartSort = true }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Smart Sort")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
                .padding(.bottom, 80)
            }
        )
        .sheet(isPresented: $showSmartSort) {
            SmartSortView()
        }
    }
}
