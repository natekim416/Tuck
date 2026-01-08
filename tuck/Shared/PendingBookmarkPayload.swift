import Foundation

struct PendingBookmarkPayload: Codable {
    enum Kind: String, Codable { case url, text, asset }

    var id: UUID = UUID()
    var kind: Kind

    var title: String
    var folder: String
    var typeRaw: String

    var url: String?
    var text: String?

    var assetRelativePath: String?
    var assetUTI: String?
    var assetFilename: String?

    var createdAt: Date = Date()
}

enum PendingStore {
    static let suite = "group.com.bookmarkapp.shared"
    static let key = "pendingBookmarksV2"

    static func load() -> [PendingBookmarkPayload] {
        guard let defaults = UserDefaults(suiteName: suite),
              let data = defaults.data(forKey: key),
              let items = try? JSONDecoder().decode([PendingBookmarkPayload].self, from: data) else {
            return []
        }
        return items
    }

    static func save(_ items: [PendingBookmarkPayload]) {
        guard let defaults = UserDefaults(suiteName: suite),
              let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: key)
    }

    static func append(_ item: PendingBookmarkPayload) {
        var items = load()
        items.append(item)
        save(items)
    }

    static func clear() {
        UserDefaults(suiteName: suite)?.removeObject(forKey: key)
    }
}
