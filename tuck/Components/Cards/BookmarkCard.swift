import SwiftUI
import UniformTypeIdentifiers

struct BookmarkCard: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    var folder: Folder?
    @State private var showingDetail = false

    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 8) {
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

                // Type badge
                HStack {
                    Image(systemName: bookmark.type.icon)
                        .font(.caption)
                    Text(bookmark.type.rawValue)
                        .font(.caption)
                    Spacer()
                    if bookmark.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .foregroundColor(.secondary)

                // Title
                Text(bookmark.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                // Key quote
                if let quote = bookmark.keyQuote {
                    Text("\"\(quote)\"")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Stats row
                HStack(spacing: 4) {
                    if bookmark.estimatedReadTime > 0 {
                        Label("\(bookmark.estimatedReadTime)m", systemImage: "book")
                    }
                    if bookmark.savedByCount > 0 {
                        if bookmark.estimatedReadTime > 0 {
                            Text("·")
                        }
                        Label("\(bookmark.savedByCount)", systemImage: "person.2")
                    }
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showingDetail) {
            BookmarkDetailView(bookmark: bookmark, viewModel: viewModel, folder: folder)
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
