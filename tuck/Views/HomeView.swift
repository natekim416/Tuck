import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var showingAddBookmark = false
    @State private var showingCreateFolder = false
    @State private var showingStaleBookmarks = false

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.folders.isEmpty {
                    ProgressView("Loading folders...")
                } else if let error = viewModel.errorMessage, viewModel.folders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            viewModel.loadFolders()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if viewModel.folders.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No folders yet")
                            .font(.title2)
                        Text("Add your first bookmark to get started")
                            .foregroundColor(.secondary)
                        Button("Add Bookmark") {
                            showingAddBookmark = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Stale bookmarks banner
                            if !viewModel.staleBookmarks.isEmpty {
                                StaleBookmarksCard(count: viewModel.staleBookmarks.count) {
                                    showingStaleBookmarks = true
                                }
                                .padding(.horizontal)
                            }

                            // Pinterest-style masonry grid of folders
                            FolderMasonryGrid(folders: viewModel.folders, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingAddBookmark = true }) {
                            Label("Add Bookmark", systemImage: "plus")
                        }
                        Button(action: { showingCreateFolder = true }) {
                            Label("Create Folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBookmark) {
                AddBookmarkView(onBookmarkSaved: {
                    viewModel.loadFolders()
                })
            }
            .sheet(isPresented: $showingCreateFolder) {
                CreateFolderView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStaleBookmarks) {
                StaleBookmarksView(viewModel: viewModel)
            }
            .refreshable {
                viewModel.loadFolders()
            }
            .onAppear {
                viewModel.syncPendingBookmarks()
                viewModel.loadFolders()
            }
        }
    }
}

// MARK: - Pinterest-style Masonry Grid for Folders

struct FolderMasonryGrid: View {
    let folders: [Folder]
    @ObservedObject var viewModel: BookmarkViewModel

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 12
            let columnWidth = (geometry.size.width - spacing) / 2

            HStack(alignment: .top, spacing: spacing) {
                // Left column
                LazyVStack(spacing: spacing) {
                    ForEach(Array(folders.enumerated()), id: \.element.id) { index, folder in
                        if index % 2 == 0 {
                            NavigationLink(destination: FolderDetailView(folder: folder, viewModel: viewModel)) {
                                PinterestFolderCard(folder: folder, columnWidth: columnWidth)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(width: columnWidth)

                // Right column
                LazyVStack(spacing: spacing) {
                    ForEach(Array(folders.enumerated()), id: \.element.id) { index, folder in
                        if index % 2 == 1 {
                            NavigationLink(destination: FolderDetailView(folder: folder, viewModel: viewModel)) {
                                PinterestFolderCard(folder: folder, columnWidth: columnWidth)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(width: columnWidth)
            }
        }
        // Estimate height based on content
        .frame(height: estimatedGridHeight)
    }

    private var estimatedGridHeight: CGFloat {
        let leftCount = folders.enumerated().filter { $0.offset % 2 == 0 }.count
        let rightCount = folders.enumerated().filter { $0.offset % 2 == 1 }.count

        // Each card has variable height; estimate based on content
        let leftHeight = folders.enumerated()
            .filter { $0.offset % 2 == 0 }
            .reduce(CGFloat(0)) { total, item in
                total + estimatedCardHeight(for: item.element) + 12
            }

        let rightHeight = folders.enumerated()
            .filter { $0.offset % 2 == 1 }
            .reduce(CGFloat(0)) { total, item in
                total + estimatedCardHeight(for: item.element) + 12
            }

        return max(leftHeight, rightHeight) + 20
    }

    private func estimatedCardHeight(for folder: Folder) -> CGFloat {
        var height: CGFloat = 16 // padding top
        
        // Thumbnail area — varies by bookmark count
        if !folder.bookmarks.isEmpty {
            // Folders with bookmarks get a taller preview
            if folder.bookmarks.count >= 4 {
                height += 140 // Grid preview
            } else {
                height += 100 // Smaller preview
            }
        } else {
            height += 70 // Icon placeholder
        }

        height += 8  // spacing
        height += 22 // folder name
        height += 4  // spacing
        height += 16 // subtitle
        height += 8  // spacing
        height += 20 // stats row
        height += 8  // spacing

        height += 16 // padding bottom
        return height
    }
}

// MARK: - Pinterest-style Folder Card

struct PinterestFolderCard: View {
    let folder: Folder
    let columnWidth: CGFloat

    private var folderColor: Color {
        Color.fromFolderName(folder.color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Preview area — varies in height based on content
            folderPreview
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(10)

            // Folder name
            Text(folder.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)

            // Description or bookmark count
            if !folder.description.isEmpty {
                Text(folder.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Stats row
            HStack(spacing: 4) {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 9))
                Text("\(folder.bookmarks.count)")
                    .font(.caption2)

                Spacer()

                if folder.isPublic {
                    Image(systemName: "globe")
                        .font(.system(size: 9))
                }

                // Show how many bookmarks have been viewed
                let viewedCount = folder.bookmarks.filter { $0.lastViewed != nil }.count
                if viewedCount > 0 {
                    Image(systemName: "eye")
                        .font(.system(size: 9))
                    Text("\(viewedCount)")
                        .font(.caption2)
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    @ViewBuilder
    private var folderPreview: some View {
        if folder.bookmarks.isEmpty {
            // Empty folder — colored icon placeholder
            VStack(spacing: 8) {
                Image(systemName: folder.icon)
                    .font(.title2)
                    .foregroundColor(folderColor)
                Text("Empty")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(folderColor.opacity(0.1))
        } else if folder.bookmarks.count >= 4 {
            // 2x2 grid thumbnail preview
            let previews = Array(folder.bookmarks.prefix(4))
            let cellSize = (columnWidth - 24 - 4) / 2 // padding + gap

            LazyVGrid(columns: [
                GridItem(.fixed(cellSize), spacing: 4),
                GridItem(.fixed(cellSize), spacing: 4)
            ], spacing: 4) {
                ForEach(previews) { bookmark in
                    bookmarkThumbnail(bookmark)
                        .frame(width: cellSize, height: cellSize * 0.75)
                        .clipped()
                        .cornerRadius(6)
                }
            }
        } else {
            // 1-3 bookmarks — stacked preview
            VStack(spacing: 4) {
                ForEach(folder.bookmarks.prefix(3)) { bookmark in
                    bookmarkThumbnail(bookmark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .clipped()
                        .cornerRadius(6)
                }
            }
        }
    }

    @ViewBuilder
    private func bookmarkThumbnail(_ bookmark: Bookmark) -> some View {
        if let imageURL = bookmark.imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(folderColor.opacity(0.15))
                    .overlay(
                        Image(systemName: bookmark.type.icon)
                            .font(.caption2)
                            .foregroundColor(folderColor)
                    )
            }
        } else {
            Rectangle()
                .fill(folderColor.opacity(0.1))
                .overlay(
                    VStack(spacing: 2) {
                        Image(systemName: bookmark.type.icon)
                            .font(.caption2)
                        Text(bookmark.displayTitle)
                            .font(.system(size: 8))
                            .lineLimit(1)
                    }
                    .foregroundColor(folderColor)
                    .padding(4)
                )
        }
    }
}
