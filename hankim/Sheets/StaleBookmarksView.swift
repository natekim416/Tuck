import SwiftUI

struct StaleBookmarksView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text("These bookmarks haven't been opened in a while")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ForEach(viewModel.staleBookmarks) { bookmark in
                    StaleBookmarkRow(bookmark: bookmark, viewModel: viewModel)
                }
            }
            .navigationTitle("Review Bookmarks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct StaleBookmarkRow: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var showingSummary = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(bookmark.title)
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: { deleteBookmark() }) {
                    Label("Delete", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.bordered)
                
                Button(action: { snooze() }) {
                    Label("Snooze", systemImage: "clock")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                
                Button(action: { showingSummary = true }) {
                    Label("Summary", systemImage: "doc.text")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .alert("AI Summary", isPresented: $showingSummary) {
            Button("OK") {}
        } message: {
            Text(bookmark.aiSummary)
        }
    }
    
    private func deleteBookmark() {
        if let folder = viewModel.folders.first(where: { $0.bookmarks.contains(bookmark) }) {
            viewModel.deleteBookmark(bookmark, from: folder)
        }
    }
    
    private func snooze() {
        viewModel.snoozeBookmark(bookmark, days: 7)
    }
}
