import SwiftUI
import UniformTypeIdentifiers

struct BookmarkDetailView: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    var folder: Folder?
    @Environment(\.presentationMode) var presentationMode
    @State private var notes: String
    @State private var showingReminder = false
    @Environment(\.dismiss) private var dismiss
    
    init(bookmark: Bookmark, viewModel: BookmarkViewModel, folder: Folder? = nil) {
        self.bookmark = bookmark
        self.viewModel = viewModel
        self.folder = folder
        _notes = State(initialValue: bookmark.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let imageURL = bookmark.imageURL,
                       let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)

                    } else if let uiImage = loadPrimaryAssetImage() {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .cornerRadius(8)

                    } else if bookmark.hasAssets {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 120)
                            Image(systemName: bookmark.type.icon)
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    }

                    
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
                    
                    HStack(spacing: 12) {
                        Button(action: { showingReminder = true }) {
                            Label("Remind", systemImage: "bell")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        if folder != nil {
                            Button(action: { toggleComplete() }) {
                                Label(bookmark.isCompleted ? "Done" : "Mark Done",
                                      systemImage: "checkmark.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    
                    if let url = bookmarkURL {
                        Link(destination: url) {
                            HStack {
                                Spacer()
                                Text("Open Link")
                                Image(systemName: "arrow.up.right")
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    } else if bookmark.assets.isEmpty {
                        // Optional: show nothing, or a subtle message
                        Text("No link")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingReminder) {
                ReminderOptionsView(bookmark: bookmark)
            }
        }
    }
    
    // MARK: - Helpers

    private var bookmarkURL: URL? {
        let s = bookmark.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        return URL(string: s)
    }

    @ViewBuilder
    private var headerPreview: some View {
        if let imageURL = bookmark.imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .frame(height: 250)
            .clipped()
            .cornerRadius(12)

        } else if let localImage = firstLocalImage() {
            Image(uiImage: localImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 250)
                .clipped()
                .cornerRadius(12)

        } else if !bookmark.assets.isEmpty {
            // Non-image asset (video/file/email) placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 250)

                VStack(spacing: 8) {
                    Image(systemName: "doc")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(bookmark.assets.first?.originalFilename ?? "Attachment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

        } else {
            EmptyView()
        }
    }

    private func firstLocalImage() -> UIImage? {
        guard let asset = bookmark.assets.first else { return nil }

        // Treat common image UTIs as image
        let isImageUTI: Bool = {
            if let ut = UTType(asset.uti) {
                return ut.conforms(to: .image)
            }
            return asset.relativePath.lowercased().hasSuffix(".jpg")
                || asset.relativePath.lowercased().hasSuffix(".jpeg")
                || asset.relativePath.lowercased().hasSuffix(".png")
        }()

        guard isImageUTI else { return nil }

        let path = SharedMediaStore.absoluteURL(for: asset.relativePath).path
        return UIImage(contentsOfFile: path)
    }

    private func toggleComplete() {
        guard let folder = folder else { return }
        viewModel.toggleBookmarkComplete(bookmark, in: folder)
        dismiss()
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
