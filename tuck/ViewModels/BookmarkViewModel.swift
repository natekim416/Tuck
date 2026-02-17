import SwiftUI
import Combine

@MainActor
public final class BookmarkViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var selectedFolder: Folder?
    @Published var bookmarks: [Bookmark] = []
    @Published var discoverFolders: [Folder] = []
    @Published var staleBookmarks: [Bookmark] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var userProfile: UserProfile = UserProfile(username: "You")

    init() { }

    // MARK: - Loaders

    func loadFolders() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let serverFolders = try await TuckServerAPI.shared.getFolders()
                
                // Fetch bookmarks for ALL folders concurrently using TaskGroup
                let foldersWithBookmarks = try await withThrowingTaskGroup(of: Folder.self) { group in
                    for folder in serverFolders {
                        group.addTask {
                            var folderCopy = folder
                            do {
                                let serverBookmarks = try await TuckServerAPI.shared.getBookmarks(folderId: folder.id)
                                folderCopy.bookmarks = serverBookmarks.map { sb in
                                    Bookmark(
                                        id: sb.id,
                                        url: sb.url,
                                        title: sb.title,
                                        notes: sb.notes,
                                        folderId: sb.folderId,
                                        createdAt: sb.createdAt
                                    )
                                }
                            } catch {
                                // Folder keeps empty bookmarks array on failure
                            }
                            return folderCopy
                        }
                    }
                    
                    var results: [Folder] = []
                    for try await folder in group {
                        results.append(folder)
                    }
                    return results
                }
                
                // Sort to maintain consistent order
                self.folders = foldersWithBookmarks.sorted { $0.name < $1.name }
                self.isLoading = false
                
                self.userProfile.totalSaves = self.folders.reduce(0) { $0 + $1.bookmarks.count }
                generateStaleBookmarks()
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func selectFolder(_ folder: Folder?) {
        selectedFolder = folder
        guard let folder else {
            bookmarks = []
            return
        }
        loadBookmarks(folderId: folder.id)
    }

    func loadBookmarks(folderId: UUID? = nil) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let serverBookmarks = try await TuckServerAPI.shared.getBookmarks(folderId: folderId)
                self.bookmarks = serverBookmarks.map { serverBookmark in
                    Bookmark(
                        id: serverBookmark.id,
                        url: serverBookmark.url,
                        title: serverBookmark.title,
                        notes: serverBookmark.notes,
                        folderId: serverBookmark.folderId,
                        createdAt: serverBookmark.createdAt
                    )
                }
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func generateStaleBookmarks() {
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
        
        staleBookmarks = folders.flatMap { $0.bookmarks }
            .filter { bookmark in
                if let lastViewed = bookmark.lastViewed {
                    return lastViewed < twoWeeksAgo
                }
                return bookmark.savedDate < twoWeeksAgo
            }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Folder Mutations

    func createFolder(name: String, color: String?) {
        Task {
            do {
                _ = try await TuckServerAPI.shared.createFolder(name: name, color: color)
                loadFolders()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func createFolder(_ folder: Folder) {
        createFolder(name: folder.name, color: folder.color)
    }
    
    func updateFolder(_ folder: Folder) {
        // Optimistic local update
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index] = folder
        }
        
        // Sync to server
        Task {
            do {
                _ = try await TuckServerAPI.shared.updateFolder(
                    id: folder.id,
                    name: folder.name,
                    color: folder.color,
                    isPublic: folder.isPublic
                )
            } catch {
                self.errorMessage = error.localizedDescription
                loadFolders() // Revert on failure
            }
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        // Optimistic local removal
        folders.removeAll { $0.id == folder.id }
        
        // Delete on server
        Task {
            do {
                try await TuckServerAPI.shared.deleteFolder(id: folder.id)
            } catch {
                self.errorMessage = error.localizedDescription
                loadFolders() // Revert on failure
            }
        }
    }
    
    // MARK: - Bookmark Mutations
    
    func addBookmark(_ bookmark: Bookmark, to folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].bookmarks.append(bookmark)
            userProfile.totalSaves += 1
        }
    }
    
    func deleteBookmark(_ bookmark: Bookmark, from folder: Folder) {
        // Optimistic local removal
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
           let bookmarkIndex = folders[folderIndex].bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            folders[folderIndex].bookmarks.remove(at: bookmarkIndex)
            userProfile.totalSaves -= 1
        }
        
        // Delete on server
        Task {
            do {
                try await TuckServerAPI.shared.deleteBookmark(id: bookmark.id)
            } catch {
                self.errorMessage = error.localizedDescription
                loadFolders()
            }
        }
    }

    func deleteBookmark(id: UUID) {
        Task {
            do {
                try await TuckServerAPI.shared.deleteBookmark(id: id)
                loadBookmarks(folderId: selectedFolder?.id)
                loadFolders()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleBookmarkComplete(_ bookmark: Bookmark, in folder: Folder) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
           let bookmarkIndex = folders[folderIndex].bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            folders[folderIndex].bookmarks[bookmarkIndex].isCompleted.toggle()
        }
    }
    
    func copyFolder(_ folder: Folder) {
        var newFolder = folder
        newFolder.id = UUID()
        newFolder.createdBy = "You (copied from \(folder.createdBy))"
        folders.append(newFolder)
    }
    
    func snoozeBookmark(_ bookmark: Bookmark, days: Int) {
        print("Snoozed \(bookmark.displayTitle) for \(days) days")
    }

    func saveBookmark(url: String, title: String?, notes: String?) {
        Task {
            do {
                let saved = try await TuckServerAPI.shared.analyzeAndSaveBookmark(url: url, title: title, notes: notes)
                loadBookmarks(folderId: saved.folder?.id ?? selectedFolder?.id)
                loadFolders()
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func syncPendingBookmarks() {
        let items = PendingStore.load()
        guard !items.isEmpty else { return }
        
        Task {
            // Process all pending bookmarks concurrently
            await withTaskGroup(of: Void.self) { group in
                for item in items {
                    group.addTask {
                        do {
                            if let url = item.url, !url.isEmpty {
                                _ = try await TuckServerAPI.shared.analyzeAndSaveBookmark(
                                    url: url,
                                    title: item.title,
                                    notes: nil
                                )
                            }
                        } catch {
                            // Silently fail individual bookmark syncs
                        }
                    }
                }
            }
            
            PendingStore.clear()
            
            await MainActor.run {
                loadFolders()
            }
        }
    }
}
