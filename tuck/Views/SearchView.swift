import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    @State private var searchText = ""
    
    var filteredBookmarks: [Bookmark] {
        if searchText.isEmpty { return [] }
        return viewModel.folders.flatMap { $0.bookmarks }.filter {
            (($0.title?.localizedCaseInsensitiveContains(searchText)) != nil) ||
            $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if searchText.isEmpty {
                    SearchEmptyState(onExampleTap: { searchText = $0 })
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(filteredBookmarks) { bookmark in
                                BookmarkCard(bookmark: bookmark, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search bookmarks")
        }
    }
}

struct SearchEmptyState: View {
    let onExampleTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("Search for anything")
                .font(.title3)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Try searching:")
                    .font(.headline)
                
                ForEach(["best places to study", "productivity tips", "design inspiration"], id: \.self) { example in
                    Button(action: { onExampleTap(example) }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text(example)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .foregroundColor(.primary)
                }
            }
            .padding()
        }
    }
}
