import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLogin = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Tuck")
                        .font(.largeTitle)
                        .bold()
                    
                    Text(isLogin ? "Welcome back" : "Create your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    
                    if !isLogin {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal)
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Action Button
                Button(action: authenticate) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isLogin ? "Login" : "Register")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(!isFormValid || isLoading)
                
                // Toggle Auth Mode
                Button(action: {
                    isLogin.toggle()
                    errorMessage = nil
                    confirmPassword = ""
                }) {
                    Text(isLogin ? "Don't have an account? Sign up" : "Already have an account? Login")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationBarHidden(true)
        }
    }
    
    var isFormValid: Bool {
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 8
        
        if isLogin {
            return emailValid && passwordValid
        } else {
            return emailValid && passwordValid && password == confirmPassword
        }
    }
    
    func authenticate() {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isLogin {
                    _ = try await TuckServerAPI.shared.login(email: email, password: password)
                } else {
                    _ = try await TuckServerAPI.shared.register(email: email, password: password)
                }
                
                await MainActor.run {
                    isAuthenticated = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    AuthView(isAuthenticated: .constant(false))
}
