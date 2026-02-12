import Foundation

struct AIAnalysisResult: Codable {
    var folders: [String]
    var deadline: String?
    var price: Double?
    var summary: String

    init(folders: [String] = [], deadline: String? = nil, price: Double? = nil, summary: String = "") {
        self.folders = folders
        self.deadline = deadline
        self.price = price
        self.summary = summary
    }

    enum CodingKeys: String, CodingKey { case folders, deadline, price, summary }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.folders = (try? c.decode([String].self, forKey: .folders)) ?? []
        self.deadline = try? c.decodeIfPresent(String.self, forKey: .deadline)
        self.price = try? c.decodeIfPresent(Double.self, forKey: .price)
        self.summary = (try? c.decode(String.self, forKey: .summary)) ?? ""
    }
}
