import SwiftUI
import UniformTypeIdentifiers

struct BookmarkDetailView: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    var folder: Folder?
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String
    @State private var showingReminder = false
    @State private var showingDeleteAlert = false
    @State private var isCompleted: Bool

    init(bookmark: Bookmark, viewModel: BookmarkViewModel, folder: Folder? = nil) {
        self.bookmark = bookmark
        self.viewModel = viewModel
        self.folder = folder
        _notes = State(initialValue: bookmark.notes ?? "")
        _isCompleted = State(initialValue: bookmark.isCompleted)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Image preview
                    if let imageURL = bookmark.imageURL,
                       let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                    } else if let uiImage = loadPrimaryAssetImage() {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                    } else if bookmark.hasAssets {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 120)
                            Image(systemName: bookmark.type.icon)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Title & type
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: bookmark.type.icon)
                            Text(bookmark.type.rawValue)
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)

                        Text(bookmark.displayTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                    }

                    // URL display
                    if !bookmark.url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(bookmark.url)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    // AI Summary
                    if !bookmark.aiSummary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("AI Summary")
                                    .font(.headline)
                            }
                            .foregroundColor(.purple)

                            Text(bookmark.aiSummary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }

                    // Notes section
                    if !(bookmark.notes ?? "").isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(bookmark.notes ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Key quote
                    if let quote = bookmark.keyQuote {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Quote")
                                .font(.headline)
                            Text("\"\(quote)\"")
                                .font(.subheadline)
                                .italic()
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }

                    // Action buttons row
                    HStack(spacing: 12) {
                        Button(action: { showingReminder = true }) {
                            Label("Remind", systemImage: "bell")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        if folder != nil {
                            if isCompleted {
                                Button(action: { toggleComplete() }) {
                                    Label("Done", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            } else {
                                Button(action: { toggleComplete() }) {
                                    Label("Mark Done", systemImage: "checkmark.circle")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    // Open Link button
                    if let url = bookmarkURL {
                        Link(destination: url) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                Text("Open Link")
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }

                    // Share button
                    Button(action: { shareBookmark() }) {
                        HStack {
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }

                    // Delete button
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        HStack {
                            Spacer()
                            Image(systemName: "trash")
                            Text("Delete Bookmark")
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingReminder) {
                ReminderOptionsView(bookmark: bookmark)
            }
            .alert("Delete Bookmark", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteBookmark()
                }
            } message: {
                Text("Are you sure you want to delete \"\(bookmark.displayTitle)\"?")
            }
        }
    }

    // MARK: - Actions

    private var bookmarkURL: URL? {
        let s = bookmark.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        // Ensure URL has a scheme
        if s.hasPrefix("http://") || s.hasPrefix("https://") {
            return URL(string: s)
        } else {
            return URL(string: "https://\(s)")
        }
    }

    private func toggleComplete() {
        guard let folder = folder else { return }
        isCompleted.toggle()
        viewModel.toggleBookmarkComplete(bookmark, in: folder)
    }

    private func deleteBookmark() {
        if let folder = folder {
            viewModel.deleteBookmark(bookmark, from: folder)
        } else {
            viewModel.deleteBookmark(id: bookmark.id)
        }
        dismiss()
    }

    private func shareBookmark() {
        var items: [Any] = [bookmark.displayTitle]
        if let url = bookmarkURL {
            items.append(url)
        }

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            activityVC.popoverPresentationController?.sourceView = topVC.view
            topVC.present(activityVC, animated: true)
        }
    }

    private func loadPrimaryAssetImage() -> UIImage? {
        guard let asset = bookmark.primaryAsset else { return nil }

        let isImage: Bool = {
            if let ut = UTType(asset.uti) { return ut.conforms(to: .image) }
            let lower = asset.relativePath.lowercased()
            return lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg") || lower.hasSuffix(".png")
        }()

        guard isImage else { return nil }

        let fileURL = SharedMediaStore.absoluteURL(for: asset.relativePath)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
