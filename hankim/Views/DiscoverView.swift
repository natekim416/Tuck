import SwiftUI

struct DiscoverView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trending Folders")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.discoverFolders.filter { $0.isPopular }) { folder in
                                    DiscoverFolderCard(folder: folder, viewModel: viewModel)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("Popular This Week")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.discoverFolders.flatMap { $0.bookmarks }
                                .sorted { $0.savedByCount > $1.savedByCount }
                                .prefix(6)) { bookmark in
                                BookmarkCard(bookmark: bookmark, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search folders and bookmarks")
        }
    }
}
