import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct BookmarkCard: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    var folder: Folder?
    @State private var showingDetail = false
    @State private var linkMetadata: LinkMetadataResult?
    @State private var isLoadingMetadata = false

    var body: some View {
        Button(action: {
            // Mark as viewed
            if let folder = folder {
                viewModel.markBookmarkViewed(bookmark, in: folder)
            }
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Link preview image
                linkPreviewImage
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(8, corners: [.topLeft, .topRight])

                VStack(alignment: .leading, spacing: 6) {
                    // Domain label
                    if let domain = extractDomain(from: bookmark.url) {
                        Text(domain)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    // Title
                    Text(linkMetadata?.title ?? bookmark.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)

                    // Bottom row: type + viewed indicator
                    HStack(spacing: 4) {
                        Image(systemName: bookmark.type.icon)
                            .font(.system(size: 10))
                        Text(bookmark.type.rawValue)
                            .font(.caption2)

                        Spacer()

                        if bookmark.lastViewed != nil {
                            HStack(spacing: 2) {
                                Image(systemName: "eye.fill")
                                    .font(.system(size: 9))
                                Text("Viewed")
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(.green)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .padding(10)
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showingDetail) {
            BookmarkDetailView(bookmark: bookmark, viewModel: viewModel, folder: folder)
        }
        .onAppear {
            loadLinkMetadata()
        }
    }

    // MARK: - Link Preview Image

    @ViewBuilder
    private var linkPreviewImage: some View {
        if let uiImage = loadPrimaryAssetImage() {
            // Local photo asset
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let imageURL = linkMetadata?.imageURL ?? bookmark.imageURL,
                  let url = URL(string: imageURL) {
            // Remote OG image or bookmark imageURL
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                domainPlaceholder
            }
        } else if isLoadingMetadata {
            ZStack {
                Rectangle().fill(Color.gray.opacity(0.1))
                ProgressView()
            }
        } else {
            domainPlaceholder
        }
    }

    private var domainPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 4) {
                Image(systemName: bookmark.type.icon)
                    .font(.title3)
                if let domain = extractDomain(from: bookmark.url) {
                    Text(domain)
                        .font(.caption2)
                        .lineLimit(1)
                }
            }
            .foregroundColor(.secondary)
        }
    }

    // MARK: - Metadata Loading

    private func loadLinkMetadata() {
        let urlString = bookmark.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !urlString.isEmpty,
              linkMetadata == nil,
              let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)") else {
            return
        }

        isLoadingMetadata = true

        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            DispatchQueue.main.async {
                isLoadingMetadata = false
                guard let metadata = metadata else { return }

                var result = LinkMetadataResult(title: metadata.title)

                // Try to get the image URL from the metadata
                if let imageProvider = metadata.imageProvider {
                    imageProvider.loadObject(ofClass: UIImage.self) { image, _ in
                        // We can't easily get a URL from LPMetadataProvider's image,
                        // but we can save it temporarily. For now just use the title.
                    }
                }

                // Use og:url or original URL for the image via a common pattern
                if let remoteURL = metadata.url ?? metadata.originalURL {
                    // Try common OG image URL patterns
                    let host = remoteURL.host ?? ""
                    if host.contains("youtube") || host.contains("youtu.be") {
                        // YouTube thumbnail
                        let videoID = extractYouTubeID(from: remoteURL.absoluteString)
                        if let videoID = videoID {
                            result.imageURL = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg"
                        }
                    }
                }

                self.linkMetadata = result
            }
        }
    }

    private func extractYouTubeID(from urlString: String) -> String? {
        if let url = URL(string: urlString) {
            if url.host?.contains("youtu.be") == true {
                return url.pathComponents.last
            }
            if let queryItems = URLComponents(string: urlString)?.queryItems {
                return queryItems.first(where: { $0.name == "v" })?.value
            }
        }
        return nil
    }

    // MARK: - Helpers

    private func extractDomain(from urlString: String) -> String? {
        let s = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return nil }
        let full = s.hasPrefix("http") ? s : "https://\(s)"
        return URL(string: full)?.host?.replacingOccurrences(of: "www.", with: "")
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

// Simple struct to hold fetched link metadata
struct LinkMetadataResult {
    var title: String?
    var imageURL: String?
}

// Rounded corner helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
