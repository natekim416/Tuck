import SwiftUI

struct FolderCard: View {
    let folder: Folder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: folder.icon)
                    .font(.title2)
                    .foregroundColor(Color(folder.color))
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
            
            HStack {
                Label("\(folder.bookmarks.count)", systemImage: "bookmark")
                Spacer()
                Label("\(folder.totalEstimatedTime)m", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if folder.progressPercentage > 0 {
                ProgressView(value: folder.progressPercentage, total: 100)
                    .tint(Color(folder.color))
                    .scaleEffect(x: 1, y: 0.5)
            }
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(Color(folder.color).opacity(0.1))
        .cornerRadius(12)
    }
}
