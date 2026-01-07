import SwiftUI

struct DiscoverFolderRow: View {
    let folder: Folder
    
    var body: some View {
        HStack(spacing: 12) {
            if let firstImage = folder.bookmarks.first?.imageURL {
                AsyncImage(url: URL(string: firstImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(folder.color).opacity(0.3))
                }
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(folder.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("by \(folder.createdBy)")
                        .font(.caption2)
                    Spacer()
                    Label("\(folder.savedByCount)", systemImage: "bookmark")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
