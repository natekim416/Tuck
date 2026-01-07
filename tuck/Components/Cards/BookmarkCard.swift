import SwiftUI

struct BookmarkCard: View {
    let bookmark: Bookmark
    @ObservedObject var viewModel: BookmarkViewModel
    var folder: Folder?
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 8) {
                if let imageURL = bookmark.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)], 
                                               startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        bookmark.isCompleted ? 
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.green)
                            .padding(8)
                        : nil,
                        alignment: .topTrailing
                    )
                }
                
                HStack {
                    Image(systemName: bookmark.type.icon)
                        .font(.caption)
                    Text(bookmark.type.rawValue)
                        .font(.caption)
                    Spacer()
                }
                .foregroundColor(.secondary)
                
                Text(bookmark.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                if let quote = bookmark.keyQuote {
                    Text("\"\(quote)\"")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 4) {
                    Label("\(bookmark.estimatedReadTime)m", systemImage: "book")
                    Text("·")
                    Label("\(bookmark.savedByCount)", systemImage: "person.2")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .sheet(isPresented: $showingDetail) {
            BookmarkDetailView(bookmark: bookmark, viewModel: viewModel, folder: folder)
        }
    }
}
