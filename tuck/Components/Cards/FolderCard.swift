import SwiftUI

extension Color {
    static func fromFolderName(_ name: String) -> Color {
        switch name.lowercased() {
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "red": return .red
        case "yellow": return .yellow
        case "gray": return .gray
        default: return .blue
        }
    }
}

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
            
            HStack {
                Label("\(folder.bookmarks.count)", systemImage: "bookmark")
                Spacer()
                Label("\(folder.totalEstimatedTime)m", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if folder.progressPercentage > 0 {
                ProgressView(value: folder.progressPercentage, total: 100)
                    .tint(c)
            }
        }
        .padding()
        .frame(width: 160, height: 160)
        .background(c.opacity(0.12))
        .cornerRadius(12)
    }
}
