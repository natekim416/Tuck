import SwiftUI

struct SignupView: View {
    @EnvironmentObject private var auth: AuthStore
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorText: String?
    @State private var isLoading = false

    private var passwordsMatch: Bool { password == confirmPassword }

    // MARK: - Validation

    private var isValidEmail: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // must end with .com
        guard trimmed.hasSuffix(".com") else { return false }

        // must contain exactly one "@"
        let parts = trimmed.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2 else { return false }

        // at least 1 char before and after "@"
        let beforeAt = parts[0]
        let afterAt = parts[1]
        guard !beforeAt.isEmpty, !afterAt.isEmpty else { return false }

        // also ensure after "@" isn't just ".com"
        guard afterAt.count > 4 else { return false } // ".com" = 4 chars

        return true
    }

    private var hasNumber: Bool {
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }

    private var hasSpecial: Bool {
        // define "special" as anything NOT letter or number
        password.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil
    }

    private var isStrongPassword: Bool {
        password.count >= 8 && hasNumber && hasSpecial
    }

    private var canSubmit: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        passwordsMatch &&
        isValidEmail &&
        isStrongPassword &&
        !isLoading
    }

    private func validationErrorMessage() -> String? {
        if email.isEmpty { return "Please enter an email." }
        if !isValidEmail { return "Email must look like name@domain.com" }

        if password.isEmpty { return "Please enter a password." }
        if password.count < 8 { return "Password must be at least 8 characters." }
        if !hasNumber { return "Password must include at least 1 number." }
        if !hasSpecial { return "Password must include at least 1 special character." }

        if !passwordsMatch { return "Passwords do not match." }

        return nil
    }

    // MARK: - UI

    var body: some View {
        VStack(spacing: 16) {
            Text("Create account")
                .font(.largeTitle)
                .bold()

            TextField("Email (name@domain.com)", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.username)
                .textFieldStyle(.roundedBorder)

            SecureField("Password (8+ chars, number, special)", text: $password)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm password", text: $confirmPassword)
                .textContentType(.newPassword)
                .textFieldStyle(.roundedBorder)

            // Inline guidance
            VStack(alignment: .leading, spacing: 6) {
                if !email.isEmpty && !isValidEmail {
                    Text("• Email must be name@domain.com and end in .com")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                if !password.isEmpty && !isStrongPassword {
                    Text("• Password needs 8+ chars, 1 number, 1 special character")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                if !confirmPassword.isEmpty && !passwordsMatch {
                    Text("• Passwords do not match")
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let errorText {
                Text(errorText).foregroundStyle(.red)
            }

            Button(isLoading ? "Creating..." : "Sign up") {
                errorText = nil

                if let msg = validationErrorMessage() {
                    errorText = msg
                    return
                }

                isLoading = true
                Task {
                    defer { isLoading = false }
                    do {
                        try await auth.signUp(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                              password: password)
                        dismiss()
                    } catch {
                        errorText = (error as? LocalizedError)?.errorDescription ?? "Sign up failed."
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit)

            Button("Already have an account? Sign in") {
                dismiss()
            }
            .font(.subheadline)
        }
        .padding()
        .navigationTitle("Sign up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
