import Foundation

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

