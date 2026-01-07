import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore

    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in").font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textContentType(.password)
                .textFieldStyle(.roundedBorder)

            if let errorText {
                Text(errorText).foregroundStyle(.red)
            }

            Button(isLoading ? "Signing in..." : "Continue") {
                errorText = nil
                isLoading = true
                Task {
                    defer { isLoading = false }
                    do {
                        try await auth.signIn(email: email, password: password)
                    } catch {
                        errorText = "Login failed. Try again."
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            NavigationLink {
                SignupView()
            } label: {
                Text("Don't have an account? Sign up.")
                    .font(.subheadline)
            }
            .padding(.top, 6)
        }
        .padding()
    }
}
