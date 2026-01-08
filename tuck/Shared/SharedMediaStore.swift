import Foundation
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#endif

enum SharedMediaStore {
    static let groupId = "group.com.bookmarkapp.shared"

    static var baseDir: URL {
        let fm = FileManager.default
        guard let container = fm.containerURL(forSecurityApplicationGroupIdentifier: groupId) else {
            fatalError("Missing App Group container. Check Capabilities + groupId.")
        }
        let dir = container.appendingPathComponent("Media", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func absoluteURL(for relativePath: String) -> URL {
        baseDir.appendingPathComponent(relativePath)
    }

    static func copyIn(from externalURL: URL, preferredFilename: String? = nil, uti: UTType? = nil) throws -> BookmarkAsset {
        let fm = FileManager.default
        let ext = externalURL.pathExtension.isEmpty ? "dat" : externalURL.pathExtension
        let filename = (preferredFilename?.isEmpty == false ? preferredFilename! : UUID().uuidString) + "." + ext
        let dest = baseDir.appendingPathComponent(filename)

        if fm.fileExists(atPath: dest.path) {
            try fm.removeItem(at: dest)
        }
        try fm.copyItem(at: externalURL, to: dest)

        let resolvedUTI = (uti ?? UTType(filenameExtension: ext) ?? .data).identifier
        return BookmarkAsset(relativePath: filename, thumbnailRelativePath: nil, uti: resolvedUTI, originalFilename: externalURL.lastPathComponent)
    }

    #if canImport(UIKit)
    static func saveJPEG(image: UIImage, compression: CGFloat = 0.9) throws -> BookmarkAsset {
        guard let data = image.jpegData(compressionQuality: compression) else {
            throw NSError(domain: "SharedMediaStore", code: 1)
        }
        let filename = UUID().uuidString + ".jpg"
        let url = baseDir.appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])

        return BookmarkAsset(relativePath: filename, thumbnailRelativePath: nil, uti: UTType.jpeg.identifier, originalFilename: filename)
    }
    #endif
}
