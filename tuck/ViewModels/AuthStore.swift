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
        let response = try await TuckServerAPI.shared.login(email: email, password: password)
        // TuckServerAPI already stores the token — just sync the user
        let loggedIn = AppUser(id: response.user.id.uuidString, email: response.user.email)
        user = loggedIn
        if let data = try? JSONEncoder().encode(loggedIn) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func signOut() {
            user = nil
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            TuckServerAPI.shared.logout()
        }
    
    func signUp(email: String, password: String) async throws {
        let response = try await TuckServerAPI.shared.register(email: email, password: password)
        let newUser = AppUser(id: response.user.id.uuidString, email: response.user.email)
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
