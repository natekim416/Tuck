import SwiftUI
import Combine

class BookmarkViewModel: ObservableObject {
    @Published var folders: [Folder] = []
    @Published var selectedFolder: Folder?
    @Published var userProfile: UserProfile
    @Published var discoverFolders: [Folder] = []
    @Published var staleBookmarks: [Bookmark] = []
    
    init() {
        self.userProfile = UserProfile(username: "You")
        loadSampleData()
        generateStaleBookmarks()
    }
    
    func loadSampleData() {
        let codingBookmarks = [
            Bookmark(
                title: "SwiftUI Complete Guide", 
                url: "https://example.com/swiftui", 
                imageURL: "https://picsum.photos/400/300?1",
                type: .article, 
                estimatedReadTime: 15, 
                estimatedSkimTime: 5,
                aiSummary: "Comprehensive guide covering SwiftUI basics to advanced topics.",
                tags: ["swift", "ios", "tutorial"],
                savedByCount: 1243,
                keyQuote: "SwiftUI makes building great UIs simple and intuitive",
                opposingViews: [
                    OpposingView(title: "Why UIKit Still Matters", url: "https://example.com/uikit", summary: "UIKit provides more control")
                ]
            ),
            Bookmark(
                title: "iOS Design Patterns",
                url: "https://example.com/patterns",
                imageURL: "https://picsum.photos/400/300?2",
                type: .video,
                estimatedReadTime: 25,
                estimatedSkimTime: 8,
                aiSummary: "Learn MVVM, Coordinator, and other essential iOS patterns.",
                tags: ["design", "architecture"],
                savedByCount: 892
            )
        ]
        
        folders = [
            Folder(
                name: "Learn to Code", 
                description: "iOS development resources",
                bookmarks: codingBookmarks,
                isPublic: true,
                color: "blue",
                icon: "chevron.left.forwardslash.chevron.right",
                savedByCount: 234,
                isPopular: true,
                outcome: .learn
            ),
            Folder(
                name: "Buy Later",
                description: "Products to purchase",
                bookmarks: [],
                color: "green",
                icon: "cart",
                outcome: .buy
            )
        ]
        
        discoverFolders = [
            Folder(
                name: "UI/UX Inspiration",
                description: "Beautiful app designs",
                bookmarks: [
                    Bookmark(
                        title: "Minimalist App Design",
                        url: "https://example.com/design1",
                        imageURL: "https://picsum.photos/400/300?6",
                        type: .article,
                        savedByCount: 4523
                    )
                ],
                isPublic: true,
                color: "pink",
                icon: "paintbrush",
                createdBy: "@designpro",
                savedByCount: 1847,
                isPopular: true
            )
        ]
        
        userProfile.totalSaves = folders.reduce(0) { $0 + $1.bookmarks.count }
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
    
    func toggleBookmarkComplete(_ bookmark: Bookmark, in folder: Folder) {
        if let folderIndex = folders.firstIndex(where: { $0.id == folder.id }),
           let bookmarkIndex = folders[folderIndex].bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            folders[folderIndex].bookmarks[bookmarkIndex].isCompleted.toggle()
        }
    }
    
    func createFolder(_ folder: Folder) {
        folders.append(folder)
    }
    
    func copyFolder(_ folder: Folder) {
        var newFolder = folder
        newFolder.id = UUID()
        newFolder.createdBy = "You (copied from \(folder.createdBy))"
        folders.append(newFolder)
    }
    
    func updateFolder(_ folder: Folder) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index] = folder
        }
    }
    
    func deleteFolder(_ folder: Folder) {
        folders.removeAll { $0.id == folder.id }
    }
    
    func snoozeBookmark(_ bookmark: Bookmark, days: Int) {
        print("Snoozed \(bookmark.title) for \(days) days")
    }
    
    func syncPendingBookmarks() {
            guard let sharedDefaults = UserDefaults(suiteName: "group.com.bookmarkapp.shared"),
                  let pendingData = sharedDefaults.array(forKey: "pendingBookmarks") as? [[String: Any]],
                  !pendingData.isEmpty else {
                return
            }
            
            for data in pendingData {
                guard let urlString = data["url"] as? String,
                      let title = data["title"] as? String,
                      let folderName = data["folder"] as? String,
                      let typeString = data["type"] as? String else {
                    continue
                }
                
                let type = BookmarkType(rawValue: typeString.capitalized) ?? .other
                let bookmark = Bookmark(
                    title: title,
                    url: urlString,
                    type: type,
                    estimatedReadTime: estimateReadTime(for: type),
                    estimatedSkimTime: estimateSkimTime(for: type),
                    aiSummary: "Added from share sheet"
                )
                
                if let existingFolder = folders.first(where: { $0.name == folderName }) {
                    addBookmark(bookmark, to: existingFolder)
                } else {
                    let newFolder = Folder(name: folderName, color: "blue", icon: "folder")
                    createFolder(newFolder)
                    if let createdFolder = folders.first(where: { $0.name == folderName }) {
                        addBookmark(bookmark, to: createdFolder)
                    }
                }
            }
            
            sharedDefaults.removeObject(forKey: "pendingBookmarks")
            sharedDefaults.synchronize()
        }
        
        private func estimateReadTime(for type: BookmarkType) -> Int {
            switch type {
            case .article: return 8
            case .video: return 15
            case .product: return 5
            case .tweet: return 1
            case .quote: return 1
            case .document: return 20
            case .other: return 5
            }
        }
        
        private func estimateSkimTime(for type: BookmarkType) -> Int {
            return max(1, estimateReadTime(for: type) / 3)
        }
    }
