import OpenAI
import Foundation

class SmartSortService {
    private let client: OpenAI
    
    init(apiKey: String) {
        self.client = OpenAI(apiToken: "apiKeyfiller")
    }
    
    func analyzeContent(text: String, userExamples: String = "") async throws -> AIAnalysisResult {
        let systemPrompt = """
        You are a smart filing assistant. Analyze the input text/URL and categorize it.
        
        Rules:
        1. Extract relevant TOPICS as folders (e.g., "College", "Duke").
        2. Identify DEADLINES (format: YYYY-MM-DD).
        3. Identify PRICE if present (number only).
        4. Return STRICT JSON.
        
        \(userExamples.isEmpty ? "" : "Here is how the user previously organized similar items:\n" + userExamples)
        """
        
        
        
//        let query = ChatQuery(
//            messages: [
//                .init(role: .system, content: systemPrompt),
//                .init(role: .user, content: text)
//            ],
//            model: .gpt4oMini,
//            responseFormat: .jsonObject
//        )
//        
//        let result = try await client.chats(query: query)
//        
//        // Decode the JSON string into our Swift Struct
//        guard let jsonString = result.choices.first?.message.content,
//              let data = jsonString.data(using: .utf8) else {
//            throw URLError(.cannotParseResponse)
//        }
//        
//        return try JSONDecoder().decode(AIAnalysisResult.self, from: data)
        return AIAnalysisResult(folders: <#T##[String]#>, summary: <#T##String#>)
    }
}
