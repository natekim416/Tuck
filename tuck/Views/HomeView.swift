import SwiftUI


struct HomeView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var showingAddBookmark = false
    @State private var showingCreateFolder = false
    @State private var showingStaleBookmarks = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !viewModel.staleBookmarks.isEmpty {
                        StaleBookmarksCard(
                            count: viewModel.staleBookmarks.count,
                            onTap: { showingStaleBookmarks = true }
                        )
                        .padding(.horizontal)
                    }
                    
                    HStack(spacing: 15) {
                        StatCard(title: "Folders", value: "\(viewModel.folders.count)", color: .blue)
                        StatCard(title: "Bookmarks", value: "\(viewModel.userProfile.totalSaves)", color: .green)
                        StatCard(title: "To Review", value: "\(viewModel.staleBookmarks.count)", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("My Folders")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: { showingCreateFolder = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.folders) { folder in
                                    NavigationLink(destination: FolderDetailView(folder: folder, viewModel: viewModel)) {
                                        FolderCard(folder: folder)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Bookmarks")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.folders.flatMap { $0.bookmarks }.prefix(6)) { bookmark in
                                BookmarkCard(bookmark: bookmark, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBookmark = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBookmark) {
                AddBookmarkView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingCreateFolder) {
                CreateFolderView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStaleBookmarks) {
                StaleBookmarksView(viewModel: viewModel)
            }
        }
    }
}
