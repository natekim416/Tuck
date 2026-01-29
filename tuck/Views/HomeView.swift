import SwiftUI

struct HomeView: View {
    @State private var folders: [Folder] = []
    @State private var isLoading = false
    @State private var showingAddBookmark = false
    @State private var errorMessage: String?
    @ObservedObject var viewModel: BookmarkViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Try Again") {
                            loadFolders()
                        }
                    }
                } else if folders.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No folders yet")
                            .font(.title2)
                        Text("Add your first bookmark to get started")
                            .foregroundColor(.secondary)
                        Button("Add Bookmark") {
                            showingAddBookmark = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(folders) { folder in
                                NavigationLink(destination: FolderDetailView(folder: folder, viewModel: viewModel)) {
                                    FolderCard(folder: folder)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBookmark = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBookmark) {
                AddBookmarkView()
            }
            .refreshable {
                loadFolders()
            }
            .onAppear {
                loadFolders()
            }
        }
    }
    
    func loadFolders() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedFolders = try await TuckServerAPI.shared.getFolders()
                await MainActor.run {
                    folders = fetchedFolders as! [Folder]
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
