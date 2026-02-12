import Foundation

class TuckServerAPI {
    static let shared = TuckServerAPI()
    
    private let baseURL = "https://tuckserverapi-production.up.railway.app"
    
    private var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    var isLoggedIn: Bool {
        authToken != nil
    }
    
    var currentUser: ServerUser? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "currentUser") else { return nil }
            return try? JSONDecoder().decode(ServerUser.self, from: data)
        }
        set {
            if let user = newValue {
                let data = try? JSONEncoder().encode(user)
                UserDefaults.standard.set(data, forKey: "currentUser")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUser")
            }
        }
    }
    
    // MARK: - Authentication
    
    func register(email: String, password: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password)
        let response: AuthResponse = try await post("/auth/register", body: request)
        authToken = response.token
        currentUser = response.user
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await post("/auth/login", body: request)
        authToken = response.token
        currentUser = response.user
        return response
    }
    
    func logout() {
        authToken = nil
        currentUser = nil
    }
    
    // MARK: - Smart Sort & Bookmarks
    
    /// Analyze and automatically save bookmark to appropriate folder
    func analyzeAndSaveBookmark(url: String, title: String?, notes: String?) async throws -> ServerSavedBookmark {
        let request = AnalyzeAndSaveRequest(url: url, title: title, notes: notes)
        return try await post("/bookmarks/smart-save", body: request, requiresAuth: true)
    }
    
    /// Just analyze without saving (for preview)
    func analyzeBookmark(url: String, title: String?, notes: String?) async throws -> AIAnalysisResult {
        let text = [url, title, notes].compactMap { $0 }.joined(separator: " ")
        let request = SmartSortRequest(text: text, userExamples: nil)
        return try await post("/smart-sort", body: request, requiresAuth: true)
    }
    
    func smartSort(text: String, userExamples: String? = nil) async throws -> AIAnalysisResult {
        let request = SmartSortRequest(text: text, userExamples: userExamples)
        return try await post("/smart-sort", body: request, requiresAuth: true)
    }
    
    // MARK: - Folders
    
    func getFolders() async throws -> [Folder] {
        return try await get("/folders", requiresAuth: true)
    }
    
    func createFolder(name: String, color: String?) async throws -> ServerFolder {
        let request = CreateFolderRequest(name: name, color: color)
        return try await post("/folders", body: request, requiresAuth: true)
    }
    
    // MARK: - Bookmarks
    
    func getBookmarks(folderId: UUID? = nil) async throws -> [ServerBookmark] {
        if let folderId = folderId {
            return try await get("/folders/\(folderId.uuidString)/bookmarks", requiresAuth: true)
        } else {
            return try await get("/bookmarks", requiresAuth: true)
        }
    }
    
    func deleteBookmark(id: UUID) async throws {
        try await delete("/bookmarks/\(id.uuidString)", requiresAuth: true)
    }
    
    // MARK: - Generic Request Methods
    
    private func get<R: Decodable>(
        _ path: String,
        requiresAuth: Bool = false
    ) async throws -> R {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.notAuthenticated
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.reason)
            }
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(R.self, from: data)
    }
    
    private func post<T: Encodable, R: Decodable>(
        _ path: String,
        body: T,
        requiresAuth: Bool = false
    ) async throws -> R {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.notAuthenticated
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.reason)
            }
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(R.self, from: data)
    }
    
    private func delete(
        _ path: String,
        requiresAuth: Bool = false
    ) async throws {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if requiresAuth {
            guard let token = authToken else {
                throw APIError.notAuthenticated
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.reason)
            }
            throw APIError.statusCode(httpResponse.statusCode)
        }
    }
}

// MARK: - Request Models

struct RegisterRequest: Codable {
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct SmartSortRequest: Codable {
    let text: String
    let userExamples: String?
}

struct AnalyzeAndSaveRequest: Codable {
    let url: String
    let title: String?
    let notes: String?
}

struct CreateFolderRequest: Codable {
    let name: String
    let color: String?
}

// MARK: - Response Models (prefixed with "Server" to avoid conflicts)

struct AuthResponse: Codable {
    let token: String
    let user: ServerUser
}

struct ServerUser: Codable {
    let id: UUID
    let email: String
}

struct ServerSavedBookmark: Codable {
    let bookmark: ServerBookmark
    let folder: Folder?
    let analysis: AIAnalysisResult?
}

struct ServerBookmark: Codable, Identifiable {
    let id: UUID
    let url: String
    let title: String?
    let notes: String?
    let folderId: UUID?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, url, title, notes
        case folderId = "folder_id"
        case createdAt = "created_at"
    }
}

struct ServerFolder: Codable, Identifiable {
    let id: UUID
    let name: String
    let color: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, color
        case createdAt = "created_at"
    }
}

struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}

// MARK: - Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case notAuthenticated
    case statusCode(Int)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .notAuthenticated:
            return "You must be logged in to perform this action"
        case .statusCode(let code):
            return "Server error (code: \(code))"
        case .serverError(let reason):
            return reason
        }
    }
    
    
    
}
