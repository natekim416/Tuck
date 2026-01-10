import Foundation

//structure we want the AI to fill out
struct AIAnalysisResult: Codable {
    var folders: [String]
    var deadline: String? //use String for easier AI parsing (ISO 8601), then convert to Date
    var price: Double?
    var summary: String
}
