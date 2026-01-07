import Foundation
import SwiftUI
import Combine

struct AppUser: Codable, Identifiable {
    let id: String
    let email: String
}

@MainActor
final class AuthStore: ObservableObject {
    @Published var user: AppUser? = nil
    @Published var isRestoringSession = true

    private let userDefaultsKey = "currentUser"

    init() {
        Task { await restoreSession() }
    }

    func restoreSession() async {
        defer { isRestoringSession = false }

        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let saved = try? JSONDecoder().decode(AppUser.self, from: data)
        else {
            user = nil
            return
        }

        user = saved
    }

    func signIn(email: String, password: String) async throws {
        // replace with real auth later
        try await Task.sleep(nanoseconds: 200_000_000)

        let loggedIn = AppUser(id: UUID().uuidString, email: email)
        user = loggedIn

        if let data = try? JSONEncoder().encode(loggedIn) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func signOut() {
        user = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func signUp(email: String, password: String) async throws {
        // replace with real signup later
        try await Task.sleep(nanoseconds: 200_000_000)

        // Tiny bit of “fake validation” so signup feels real
        guard email.contains("@"), email.contains(".") else {
            throw AuthError.invalidEmail
        }
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        let newUser = AppUser(id: UUID().uuidString, email: email)
        user = newUser

        if let data = try? JSONEncoder().encode(newUser) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    enum AuthError: LocalizedError {
        case invalidEmail
        case weakPassword

        var errorDescription: String? {
            switch self {
            case .invalidEmail: return "Please enter a valid email."
            case .weakPassword: return "Password must be at least 6 characters."
            }
        }
    }

}
