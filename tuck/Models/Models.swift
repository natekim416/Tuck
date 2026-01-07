import SwiftUI

struct Bookmark: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var url: String
    var imageURL: String?
    var type: BookmarkType
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
    
    init(id: UUID = UUID(), title: String, url: String, imageURL: String? = nil,
         type: BookmarkType, estimatedReadTime: Int = 5, estimatedSkimTime: Int = 2,
         notes: String = "", aiSummary: String = "", tags: [String] = [],
         savedByCount: Int = 0, keyQuote: String? = nil, opposingViews: [OpposingView] = []) {
        self.id = id
        self.title = title
        self.url = url
        self.imageURL = imageURL
        self.type = type
        self.estimatedReadTime = estimatedReadTime
        self.estimatedSkimTime = estimatedSkimTime
        self.notes = notes
        self.aiSummary = aiSummary
        self.savedDate = Date()
        self.tags = tags
        self.isCompleted = false
        self.savedByCount = savedByCount
        self.keyQuote = keyQuote
        self.opposingViews = opposingViews
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

enum BookmarkType: String, Codable, CaseIterable {
    case article = "Article"
    case video = "Video"
    case product = "Product"
    case tweet = "Tweet"
    case quote = "Quote"
    case document = "Document"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .article: return "doc.text"
        case .video: return "play.rectangle"
        case .product: return "cart"
        case .tweet: return "message"
        case .quote: return "quote.bubble"
        case .document: return "doc"
        case .other: return "link"
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
