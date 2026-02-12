import Foundation

struct Bookmark: Identifiable, Codable, Hashable {
    let id: UUID

    // Core
    var title: String
    var type: BookmarkType

    var url: String?                 // for link-like items
    var imageURL: String?            // remote preview image (optional, keep for now)
    var assets: [BookmarkAsset]      // local files (photos, videos, pdfs, eml, etc.)

    // Existing metadata
    var estimatedReadTime: Int
    var estimatedSkimTime: Int
    var notes: String
    var aiSummary: String
    var savedDate: Date
    var lastViewed: Date?
    var tags: [String]
    var isCompleted: Bool
    var reminderDate: Date?
    var reminderContext: ReminderContext?
    var savedByCount: Int
    var keyQuote: String?
    var opposingViews: [OpposingView]

    // Convenience helpers to reduce callsite pain
    var urlString: String { url?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
    var hasURL: Bool { !urlString.isEmpty }
    var hasAssets: Bool { !assets.isEmpty }
    var primaryAsset: BookmarkAsset? { assets.first }

    init(
        id: UUID = UUID(),
        title: String,
        url: String? = nil,
        imageURL: String? = nil,
        type: BookmarkType,
        assets: [BookmarkAsset] = [],
        estimatedReadTime: Int = 0,
        estimatedSkimTime: Int = 0,
        notes: String = "",
        aiSummary: String = "",
        tags: [String] = [],
        savedByCount: Int = 0,
        keyQuote: String? = nil,
        opposingViews: [OpposingView] = []
    ) {
        self.id = id
        self.title = title
        self.url = url
        self.imageURL = imageURL
        self.type = type
        self.assets = assets
        self.estimatedReadTime = estimatedReadTime
        self.estimatedSkimTime = estimatedSkimTime
        self.notes = notes
        self.aiSummary = aiSummary
        self.savedDate = Date()
        self.lastViewed = nil
        self.tags = tags
        self.isCompleted = false
        self.reminderDate = nil
        self.reminderContext = nil
        self.savedByCount = savedByCount
        self.keyQuote = keyQuote
        self.opposingViews = opposingViews
    }

    // Backward-friendly Codable (so old saved data doesn’t crash when you add assets / make url optional)
    enum CodingKeys: String, CodingKey {
        case id, title, url, imageURL, type, assets
        case estimatedReadTime, estimatedSkimTime, notes, aiSummary, savedDate, lastViewed, tags, isCompleted
        case reminderDate, reminderContext, savedByCount, keyQuote, opposingViews
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        type = (try? c.decode(BookmarkType.self, forKey: .type)) ?? .other

        // url becomes nil if empty
        let rawURL = try c.decodeIfPresent(String.self, forKey: .url)
        let trimmed = rawURL?.trimmingCharacters(in: .whitespacesAndNewlines)
        url = (trimmed?.isEmpty == false) ? trimmed : nil

        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
        assets = try c.decodeIfPresent([BookmarkAsset].self, forKey: .assets) ?? []

        estimatedReadTime = try c.decodeIfPresent(Int.self, forKey: .estimatedReadTime) ?? 0
        estimatedSkimTime = try c.decodeIfPresent(Int.self, forKey: .estimatedSkimTime) ?? 0
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        aiSummary = try c.decodeIfPresent(String.self, forKey: .aiSummary) ?? ""
        savedDate = try c.decodeIfPresent(Date.self, forKey: .savedDate) ?? Date()
        lastViewed = try c.decodeIfPresent(Date.self, forKey: .lastViewed)

        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        reminderDate = try c.decodeIfPresent(Date.self, forKey: .reminderDate)
        reminderContext = try c.decodeIfPresent(ReminderContext.self, forKey: .reminderContext)

        savedByCount = try c.decodeIfPresent(Int.self, forKey: .savedByCount) ?? 0
        keyQuote = try c.decodeIfPresent(String.self, forKey: .keyQuote)
        opposingViews = try c.decodeIfPresent([OpposingView].self, forKey: .opposingViews) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)

        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(type, forKey: .type)

        try c.encodeIfPresent(url, forKey: .url)
        try c.encodeIfPresent(imageURL, forKey: .imageURL)
        try c.encode(assets, forKey: .assets)

        try c.encode(estimatedReadTime, forKey: .estimatedReadTime)
        try c.encode(estimatedSkimTime, forKey: .estimatedSkimTime)
        try c.encode(notes, forKey: .notes)
        try c.encode(aiSummary, forKey: .aiSummary)
        try c.encode(savedDate, forKey: .savedDate)
        try c.encodeIfPresent(lastViewed, forKey: .lastViewed)

        try c.encode(tags, forKey: .tags)
        try c.encode(isCompleted, forKey: .isCompleted)
        try c.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try c.encodeIfPresent(reminderContext, forKey: .reminderContext)

        try c.encode(savedByCount, forKey: .savedByCount)
        try c.encodeIfPresent(keyQuote, forKey: .keyQuote)
        try c.encode(opposingViews, forKey: .opposingViews)
    }
}

struct OpposingView: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var url: String
    var summary: String
    
    init(id: UUID = UUID(), title: String, url: String, summary: String) {
        self.id = id
        self.title = title
        self.url = url
        self.summary = summary
    }
}

enum BookmarkType: String, Codable, CaseIterable, Hashable {
    case article = "Article"
    case video = "Video"
    case product = "Product"
    case tweet = "Tweet"
    case quote = "Quote"
    case document = "Document"
    case photo = "Photo"
    case screenshot = "Screenshot"
    case email = "Email"
    case other = "Other"

    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .product: return "cart"
        case .tweet: return "message"
        case .quote: return "quote.bubble"
        case .document: return "doc"
        case .photo: return "photo"
        case .screenshot: return "rectangle.dashed"
        case .email: return "envelope"
        case .other: return "link"
        }
    }

    /// Use this to drive AddBookmarkView validation
    var prefersURL: Bool {
        switch self {
        case .article, .product, .tweet:
            return true
        case .video, .document, .other:
            return true // can be URL OR file; you choose UI behavior
        case .photo, .screenshot, .email, .quote:
            return false
        }
    }

    var prefersAssets: Bool {
        switch self {
        case .photo, .screenshot, .email, .document, .video:
            return true
        default:
            return false
        }
    }
}


enum ReminderContext: String, Codable, CaseIterable {
    case atHome = "At Home"
    case atSchool = "At School"
    case openYouTube = "When opening YouTube"
    case openChrome = "When opening Chrome"
    case twoWeeks = "In 2 weeks if not opened"
    case weekend = "This weekend"
    case custom = "Custom"
    
    var icon: String {
        switch self {
        case .atHome: return "house"
        case .atSchool: return "book"
        case .openYouTube: return "play.rectangle"
        case .openChrome: return "globe"
        case .twoWeeks: return "calendar"
        case .weekend: return "calendar.badge.clock"
        case .custom: return "bell"
        }
    }
}

struct Folder: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var description: String
    var bookmarks: [Bookmark]
    var isPublic: Bool
    var color: String
    var icon: String
    var createdBy: String
    var savedByCount: Int
    var isPopular: Bool
    var collaborators: [String]
    var outcome: FolderOutcome
    
    var totalEstimatedTime: Int {
        bookmarks.reduce(0) { $0 + $1.estimatedReadTime }
    }
    
    var completedCount: Int {
        bookmarks.filter { $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        guard !bookmarks.isEmpty else { return 0 }
        return Double(completedCount) / Double(bookmarks.count) * 100
    }
    
    init(id: UUID = UUID(), name: String, description: String = "",
         bookmarks: [Bookmark] = [], isPublic: Bool = false,
         color: String = "blue", icon: String = "folder",
         createdBy: String = "You", savedByCount: Int = 0, isPopular: Bool = false,
         collaborators: [String] = [], outcome: FolderOutcome = .learn) {
        self.id = id
        self.name = name
        self.description = description
        self.bookmarks = bookmarks
        self.isPublic = isPublic
        self.color = color
        self.icon = icon
        self.createdBy = createdBy
        self.savedByCount = savedByCount
        self.isPopular = isPopular
        self.collaborators = collaborators
        self.outcome = outcome
    }
    
    // Custom decoder to handle server response with missing fields
    enum CodingKeys: String, CodingKey {
        case id, name, description, bookmarks, isPublic, color, icon
        case createdBy, savedByCount, isPopular, collaborators, outcome
        case createdAt, user
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.description = (try? c.decode(String.self, forKey: .description)) ?? ""
        self.bookmarks = (try? c.decode([Bookmark].self, forKey: .bookmarks)) ?? []
        self.isPublic = (try? c.decode(Bool.self, forKey: .isPublic)) ?? false
        self.color = (try? c.decode(String.self, forKey: .color)) ?? "blue"
        self.icon = (try? c.decode(String.self, forKey: .icon)) ?? "folder"
        self.createdBy = (try? c.decode(String.self, forKey: .createdBy)) ?? "You"
        self.savedByCount = (try? c.decode(Int.self, forKey: .savedByCount)) ?? 0
        self.isPopular = (try? c.decode(Bool.self, forKey: .isPopular)) ?? false
        self.collaborators = (try? c.decode([String].self, forKey: .collaborators)) ?? []
        self.outcome = (try? c.decode(FolderOutcome.self, forKey: .outcome)) ?? .learn
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(bookmarks, forKey: .bookmarks)
        try c.encode(isPublic, forKey: .isPublic)
        try c.encode(color, forKey: .color)
        try c.encode(icon, forKey: .icon)
        try c.encode(createdBy, forKey: .createdBy)
        try c.encode(savedByCount, forKey: .savedByCount)
        try c.encode(isPopular, forKey: .isPopular)
        try c.encode(collaborators, forKey: .collaborators)
        try c.encode(outcome, forKey: .outcome)
    }
}

enum FolderOutcome: String, Codable, CaseIterable {
    case learn = "Learn"
    case buy = "Buy"
    case watch = "Watch"
    case read = "Read"
    case research = "Research"
    case inspiration = "Inspiration"
    case reference = "Reference"
    
    var icon: String {
        switch self {
        case .learn: return "brain"
        case .buy: return "cart"
        case .watch: return "play.circle"
        case .read: return "book"
        case .research: return "magnifyingglass"
        case .inspiration: return "lightbulb"
        case .reference: return "bookmark"
        }
    }
    
    var color: String {
        switch self {
        case .learn: return "blue"
        case .buy: return "green"
        case .watch: return "red"
        case .read: return "orange"
        case .research: return "purple"
        case .inspiration: return "pink"
        case .reference: return "gray"
        }
    }
}

struct UserProfile: Codable {
    var username: String
    var displayName: String
    var bio: String
    var followers: Int
    var following: Int
    var totalSaves: Int
    var profileImageURL: String?
    var interests: [String]
    
    init(username: String, displayName: String = "", bio: String = "",
         followers: Int = 0, following: Int = 0, totalSaves: Int = 0,
         profileImageURL: String? = nil, interests: [String] = []) {
        self.username = username
        self.displayName = displayName.isEmpty ? username : displayName
        self.bio = bio
        self.followers = followers
        self.following = following
        self.totalSaves = totalSaves
        self.profileImageURL = profileImageURL
        self.interests = interests
    }
}
