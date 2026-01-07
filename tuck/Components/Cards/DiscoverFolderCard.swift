import SwiftUI

struct DiscoverFolderCard: View {
    let folder: Folder
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 10) {
                if let firstImage = folder.bookmarks.first?.imageURL {
                    AsyncImage(url: URL(string: firstImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(folder.color).opacity(0.3))
                    }
                    .frame(width: 200, height: 150)
                    .clipped()
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(folder.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("by \(folder.createdBy)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(folder.savedByCount)", systemImage: "bookmark")
                        Spacer()
                        Label("\(folder.bookmarks.count) items", systemImage: "square.grid.2x2")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
            }
            .frame(width: 200)
        }
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                FolderDetailView(folder: folder, viewModel: viewModel)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Copy") {
                                viewModel.copyFolder(folder)
                                showingDetail = false
                            }
                        }
                    }
            }
        }
    }
}
