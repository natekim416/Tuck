import SwiftUI

struct FolderCard: View {
    let folder: Folder

    private var c: Color {
        Color.fromFolderName(folder.color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: folder.icon)
                    .foregroundColor(c)
                Spacer()
                if folder.isPublic {
                    Image(systemName: "globe")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(folder.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)

            if !folder.description.isEmpty {
                Text(folder.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Label("\(folder.bookmarks.count)", systemImage: "bookmark")
                Spacer()
                let viewedCount = folder.bookmarks.filter { $0.lastViewed != nil }.count
                if viewedCount > 0 {
                    Label("\(viewedCount)", systemImage: "eye")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(c.opacity(0.12))
        .cornerRadius(12)
    }
}
