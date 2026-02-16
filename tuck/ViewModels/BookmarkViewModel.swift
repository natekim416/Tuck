//import SwiftUI
//import Combine
//
//public class BookmarkViewModel: ObservableObject {
//    @Published var folders: [Folder] = []
//    @Published var selectedFolder: Folder?
//    @Published var userProfile: UserProfile
//    @Published var discoverFolders: [Folder] = []
//    @Published var staleBookmarks: [Bookmark] = []
//
//    init() {
//        self.userProfile = UserProfile(username: "You")
//        loadSampleData()
//        generateStaleBookmarks()
//    }
//
//    func loadSampleData() {
//        let codingBookmarks = [
//            Bookmark(
//                title: "SwiftUI Complete Guide",
//                url: "https://example.com/swiftui",
//                imageURL: "https://picsum.photos/400/300?1",
//                type: .article,
//                estimatedReadTime: 15,
//                estimatedSkimTime: 5,
//                aiSummary: "Comprehensive guide covering SwiftUI basics to advanced topics.",
//                tags: ["swift", "ios", "tutorial"],
//                savedByCount: 1243,
//                keyQuote: "SwiftUI makes building great UIs simple and intuitive",
//                opposingViews: [
//                    OpposingView(title: "Why UIKit Still Matters", url: "https://example.com/uikit", summary: "UIKit provides more control")
//                ]
//            ),
//            Bookmark(
//                title: "iOS Design Patterns",
//                url: "https://example.com/patterns",
//                imageURL: "https://picsum.photos/400/300?2",
//                type: .video,
//                estimatedReadTime: 25,
//                estimatedSkimTime: 8,
//                aiSummary: "Learn MVVM, Coordinator, and other essential iOS patterns.",
//                tags: ["design", "architecture"],
//                savedByCount: 892
//            )
//        ]
//
//        folders = [
//            Folder(
//                name: "Learn to Code",
//                description: "iOS development resources",
//                bookmarks: codingBookmarks,
//                isPublic: true,
//                color: "blue",
//                icon: "chevron.left.forwardslash.chevron.right",
//                savedByCount: 234,
//                isPopular: true,
//                outcome: .learn
//            ),
//            Folder(
//                name: "Buy Later",
//                description: "Products to purchase",
//                bookmarks: [],
//                color: "green",
//                icon: "cart",
//                outcome: .buy
//            )
//        ]
//
//        discoverFolders = [
//            Folder(
//                name: "UI/UX Inspiration",
//                description: "Beautiful app designs",
//                bookmarks: [
//                    Bookmark(
//                        title: "Minimalist App Design",
//                        url: "https://example.com/design1",
//                        imageURL: "https://picsum.photos/400/300?6",
//                        type: .article,
//                        savedByCount: 4523
//                    )
//                ],
//                isPublic: true,
//                color: "pink",
//                icon: "paintbrush",
//                createdBy: "@designpro",
//                savedByCount: 1847,
//                isPopular: true
//            )
//        ]
//
//        userProfile.totalSaves = folders.reduce(0) { $0 + $1.bookmarks.count }
//    }
//
//    func generateStaleBookmarks() {
//        let calendar = Calendar.current
//        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
//
//        staleBookmarks = folders.flatMap { $0.bookmarks }
//            .filter { bookmark in
//                if let lastViewed = bookmark.lastViewed {
//                    return lastViewed < twoWeeksAgo
//                }
//                return bookmark.savedDate < twoWeeksAgo
//            }
//            .prefix(5)
//            .map { $0 }
//    }
//
//    func addBookmark(_ bookmark: Bookmark, to folder: Folder) {
//        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
//            folders[index].bookmarks.append(bookmark)
//            userProfile.totalSaves += 1
//        }
//    }
//
//    func deleteBookmark(_ bookmark: Bookmark, from folder: Folder) {
//        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
//           let bookmarkIndex = folders[folderIndex].bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
//            folders[folderIndex].bookmarks.remove(at: bookmarkIndex)
//            userProfile.totalSaves -= 1
//        }
//    }
//
//    func toggleBookmarkComplete(_ bookmark: Bookmark, in folder: Folder) {
//        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
//           let bookmarkIndex = folders[folderIndex].bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
//            folders[folderIndex].bookmarks[bookmarkIndex].isCompleted.toggle()
//        }
//    }
//
//    func createFolder(_ folder: Folder) {
//        folders.append(folder)
//
//        // Also save to server
//        Task {
//            do {
//                _ = try await TuckServerAPI.shared.createFolder(name: folder.name, color: folder.color)
//            } catch {
//                print("Failed to save folder to server: \(error)")
//            }
//        }
//    }
//
//    func copyFolder(_ folder: Folder) {
//        var newFolder = folder
//        newFolder.id = UUID()
//        newFolder.createdBy = "You (copied from \(folder.createdBy))"
//        folders.append(newFolder)
//    }
//
//    func updateFolder(_ folder: Folder) {
//        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
//            folders[index] = folder
//        }
//    }
//
//    func deleteFolder(_ folder: Folder) {
//        folders.removeAll { $0.id == folder.id }
//    }
//
//    func snoozeBookmark(_ bookmark: Bookmark, days: Int) {
//        print("Snoozed \(bookmark.title) for \(days) days")
//    }
//
//    func syncPendingBookmarks() {
//        let items = PendingStore.load()
//        guard !items.isEmpty else { return }
//
//        for item in items {
//            let type = BookmarkType(rawValue: item.typeRaw) ?? .other
//
//            var assets: [BookmarkAsset] = []
//            if let rel = item.assetRelativePath, let uti = item.assetUTI {
//                assets = [BookmarkAsset(relativePath: rel, thumbnailRelativePath: nil, uti: uti, originalFilename: item.assetFilename)]
//            }
//
//            let bookmark = Bookmark(
//                title: item.title,
//                url: item.url,                 // optional
//                imageURL: nil,
//                type: type,
//                assets: assets,
////                estimatedReadTime: estimateReadTime(for: type),
////                estimatedSkimTime: estimateSkimTime(for: type),
//                aiSummary: "Added from share sheet"
//            )
//
//            if let existingFolder = folders.first(where: { $0.name == item.folder }) {
//                addBookmark(bookmark, to: existingFolder)
//            } else {
//                let newFolder = Folder(name: item.folder, color: "blue", icon: "folder")
//                createFolder(newFolder)
//                if let created = folders.first(where: { $0.name == item.folder }) {
//                    addBookmark(bookmark, to: created)
//                }
//            }
//        }
//
//        PendingStore.clear()
//    }
//}
//
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
                self.folders = serverFolders
                self.isLoading = false
                
                // Update user profile stats
                self.userProfile.totalSaves = serverFolders.reduce(0) { $0 + $1.bookmarks.count }
                
                // Generate stale bookmarks
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
                self.bookmarks = serverBookmarks as! [Bookmark]
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

    // MARK: - Mutations

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
        // Use the existing method with name and color from the folder
        createFolder(name: folder.name, color: folder.color)
    }
    
    func updateFolder(_ folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index] = folder
        }
        // TODO: Add server sync when endpoint exists
    }
    
    func deleteFolder(_ folder: Folder) {
        folders.removeAll { $0.id == folder.id }
        // TODO: Add server deletion when endpoint exists
    }
    
    func addBookmark(_ bookmark: Bookmark, to folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].bookmarks.append(bookmark)
            userProfile.totalSaves += 1
        }
    }
    
    func deleteBookmark(_ bookmark: Bookmark, from folder: Folder) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
           let bookmarkIndex = folders[folderIndex].bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            folders[folderIndex].bookmarks.remove(at: bookmarkIndex)
            userProfile.totalSaves -= 1
        }
    }

    func deleteBookmark(id: UUID) {
        Task {
            do {
                try await TuckServerAPI.shared.deleteBookmark(id: id)
                loadBookmarks(folderId: selectedFolder?.id)
                loadFolders() // Refresh to update counts
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
                loadFolders() // Refresh folders to update counts
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func syncPendingBookmarks() {
        let items = PendingStore.load()
        guard !items.isEmpty else { return }
        
        for item in items {
            // Create bookmark from pending item and save via API
            saveBookmark(url: item.url ?? "", title: item.title, notes: nil)
        }
        
        PendingStore.clear()
    }
}
