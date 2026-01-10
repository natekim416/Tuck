import Foundation

struct BookmarkAsset: Identifiable, Codable, Hashable {
    var id: UUID = UUID()

    //path inside the app ("A1B2C3.jpg")
    var relativePath: String

    //optional thumbnail for fast grid rendering
    var thumbnailRelativePath: String?

    //uniform type identifiers
    var uti: String

    var originalFilename: String?
    var createdAt: Date = Date()
}
