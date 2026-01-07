import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore

    @State private var email = ""
    @State private var password = ""
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in").font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if let errorText {
                Text(errorText).foregroundStyle(.red)
            }
            HStack(spacing: 16){
                Button("Continue") {
                    errorText = nil
                    Task {
                        do {
                            try await auth.signIn(email: email, password: password)
                        } catch {
                            errorText = "Login failed. Try again."
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty)
                
                Button("Sign up") {
                    NavigationLink(destination: SignupView()) {
                        Text("Don't have an account? Sign up.")
                    }
                }
            }
        }
        .padding()
    }
}
