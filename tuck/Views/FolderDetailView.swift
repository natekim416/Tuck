import SwiftUI

struct FolderDetailView: View {
    let folder: Folder
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var showingAddBookmark = false
    @State private var localFolder: Folder
    
    init(folder: Folder, viewModel: BookmarkViewModel) {
        self.folder = folder
        self.viewModel = viewModel
        _localFolder = State(initialValue: folder)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                FolderHeaderView(folder: localFolder)
                    .padding(.horizontal)
                
                if !localFolder.bookmarks.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(localFolder.completedCount)/\(localFolder.bookmarks.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: localFolder.progressPercentage, total: 100)
                            .tint(Color(localFolder.color))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                if localFolder.bookmarks.isEmpty {
                    EmptyFolderView(onAddBookmark: { showingAddBookmark = true })
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(localFolder.bookmarks) { bookmark in
                            BookmarkCard(bookmark: bookmark, viewModel: viewModel, folder: localFolder)
                        }
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.discoverFolders.isEmpty {
                        MoreIdeasSection(viewModel: viewModel)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddBookmark = true }) {
                        Label("Add Bookmark", systemImage: "plus")
                    }
                    Button(action: { togglePublic() }) {
                        Label(localFolder.isPublic ? "Make Private" : "Make Public", 
                              systemImage: localFolder.isPublic ? "lock" : "globe")
                    }
                    Button(action: {}) {
                        Label("Share Folder", systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button(role: .destructive, action: { deleteFolder() }) {
                        Label("Delete Folder", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddBookmark) {
//            AddBookmarkView(viewModel: viewModel, selectedFolder: localFolder)
              AddBookmarkView()
        }
        .onAppear {
            if let updated = viewModel.folders.first(where: { $0.id == folder.id }) {
                localFolder = updated
            }
        }
    }
    
    private func togglePublic() {
        localFolder.isPublic.toggle()
        viewModel.updateFolder(localFolder)
    }
    
    private func deleteFolder() {
        viewModel.deleteFolder(localFolder)
    }
}

struct FolderHeaderView: View {
    let folder: Folder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: folder.icon)
                    .font(.title)
                    .foregroundColor(Color(folder.color))
                Text(folder.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            if !folder.description.isEmpty {
                Text(folder.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(folder.bookmarks.count) items", systemImage: "bookmark")
                Spacer()
                Label("\(folder.totalEstimatedTime) min", systemImage: "clock")
                Spacer()
                if folder.isPublic {
                    Label("\(folder.savedByCount) saves", systemImage: "person.2")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(folder.color).opacity(0.1))
        .cornerRadius(12)
    }
}

struct EmptyFolderView: View {
    let onAddBookmark: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No bookmarks yet")
                .font(.title3)
                .foregroundColor(.secondary)
            Button("Add First Bookmark") {
                onAddBookmark()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct MoreIdeasSection: View {
    @ObservedObject var viewModel: BookmarkViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                Text("More ideas for this folder")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.discoverFolders.prefix(3)) { folder in
                        DiscoverFolderCard(folder: folder, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 20)
    }
}
