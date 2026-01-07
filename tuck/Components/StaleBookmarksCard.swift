import SwiftUI

struct StaleBookmarksCard: View {
    let count: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(count) bookmarks need attention")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Delete, snooze, or summarize?")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
    }
}
