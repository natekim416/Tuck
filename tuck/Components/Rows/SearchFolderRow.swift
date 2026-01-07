import SwiftUI

struct SearchFolderRow: View {
    let folder: Folder
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: folder.icon)
                .font(.title2)
                .foregroundColor(Color(folder.color))
                .frame(width: 50, height: 50)
                .background(Color(folder.color).opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(folder.bookmarks.count) bookmarks · by \(folder.createdBy)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}
