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
