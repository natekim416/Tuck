import SwiftUI

struct AddBookmarkView: View {
    @ObservedObject var viewModel: BookmarkViewModel
    var selectedFolder: Folder?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var url: String = ""
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var selectedType: BookmarkType = .article
    @State private var selectedFolderId: UUID?
    @State private var tags: String = ""
    @State private var isProcessing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Bookmark Details") {
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                    
                    TextField("Title", text: $title)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(BookmarkType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("Folder") {
                    Picker("Save to", selection: $selectedFolderId) {
                        ForEach(viewModel.folders) { folder in
                            HStack {
                                Image(systemName: folder.icon)
                                    .foregroundColor(Color(folder.color))
                                Text(folder.name)
                            }
                            .tag(folder.id as UUID?)
                        }
                    }
                }
                
                Section("Optional") {
                    TextField("Tags (comma separated)", text: $tags)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if isProcessing {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Text("Processing...")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Add Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBookmark()
                    }
                    .disabled(url.isEmpty || selectedFolderId == nil)
                }
            }
            .onAppear {
                if let folder = selectedFolder {
                    selectedFolderId = folder.id
                } else if let firstFolder = viewModel.folders.first {
                    selectedFolderId = firstFolder.id
                }
            }
        }
    }
    
    private func saveBookmark() {
        guard let folderId = selectedFolderId,
              let folder = viewModel.folders.first(where: { $0.id == folderId }) else {
            return
        }
        
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            
            let bookmark = Bookmark(
                title: title.isEmpty ? extractTitle(from: url) : title,
                url: url,
                imageURL: "https://picsum.photos/400/300?\(Int.random(in: 1...100))",
                type: selectedType,
                estimatedReadTime: Int.random(in: 5...20),
                estimatedSkimTime: Int.random(in: 2...8),
                notes: notes,
                aiSummary: "AI-generated summary of this \(selectedType.rawValue.lowercased())",
                tags: tagArray
            )
            
            viewModel.addBookmark(bookmark, to: folder)
            isProcessing = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func extractTitle(from urlString: String) -> String {
        guard let url = URL(string: urlString),
              let host = url.host else {
            return "Untitled Bookmark"
        }
        return host.replacingOccurrences(of: "www.", with: "").capitalized
    }
}
