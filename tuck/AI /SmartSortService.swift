import Foundation

class SmartSortService {
    static let shared = SmartSortService()
    
    private init() {}
    
    /// Analyze text using the TuckServer backend
    func analyze(text: String, userExamples: String? = nil) async throws -> AIAnalysisResult {
        // Use analyzeBookmark which sends to /smart-sort endpoint
        return try await TuckServerAPI.shared.analyzeBookmark(
            url: text,
            title: nil,
            notes: userExamples
        )
    }
    
    /// Analyze and save bookmark automatically to the right folder
    func analyzeAndSave(url: String, title: String? = nil, notes: String? = nil) async throws -> ServerSavedBookmark {
        return try await TuckServerAPI.shared.analyzeAndSaveBookmark(
            url: url,
            title: title,
            notes: notes
        )
    }
}
