import Foundation

class TuckServerAPI {
    static let shared = TuckServerAPI()
    
    // 🚨 REPLACE THIS with your Railway URL after deployment
    // Get it by running: railway domain
    private let baseURL = "https://your-app-name.up.railway.app"
    
    // Token storage
    private var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    var isLoggedIn: Bool {
        authToken != nil
    }
    
    var currentToken: String? {
        authToken
    }
    
    // MARK: - Authentication
    
    func register(email: String, password: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password)
        let response: AuthResponse = try await post("/auth/register", body: request)
        authToken = response.token
        return response
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await post("/auth/login", body: request)
        authToken = response.token
        return response
    }
    
    func logout() {
        authToken = nil
    }
    
    // MARK: - Smart Sort
    
    func smartSort(text: String, userExamples: String? = nil) async throws -> AIAnalysisResult {
        let request = SmartSortRequest(text: text, userExamples: userExamples)
        return try await post("/smart-sort", body: request, requiresAuth: true)
    }
    
    // MARK: - Generic Request Methods
    
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
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error response
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.reason)
            }
            throw APIError.statusCode(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(R.self, from: data)
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

// MARK: - Response Models

struct AuthResponse: Codable {
    let token: String
    let user: PublicUser
}

struct PublicUser: Codable {
    let id: UUID
    let email: String
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