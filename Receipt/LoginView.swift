import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager

    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showPassword = false
    @State private var showingCreateAccount = false
    @State private var showingRecoverAccount = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Welcome Back")
                    .font(.largeTitle.bold())

                Text("Log in to securely access your receipt data.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .textContentType(.username)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    HStack {
                        Group {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.asciiCapable)
                                    .textContentType(.password)
                            } else {
                                SecureField("Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .keyboardType(.asciiCapable)
                                    .textContentType(.password)
                            }
                        }

                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 10) {
                    Button("Login") {
                        handleLogin()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                    Button("Forgot Username or Password?") {
                        showingRecoverAccount = true
                    }
                    .font(.subheadline)

                    Button("Create New Account") {
                        showingCreateAccount = true
                    }
                    .font(.subheadline)

                    if authManager.hasStoredPassword &&
                        authManager.biometricsAvailable &&
                        authManager.biometricsEnabled {
                        Button("Use Face ID / Touch ID") {
                            Task {
                                let success = await authManager.authenticateWithBiometrics()
                                if !success {
                                    errorMessage = "Biometric authentication failed."
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .onAppear {
                if !authManager.savedUsername.isEmpty {
                    username = authManager.savedUsername
                }
            }
            .sheet(isPresented: $showingCreateAccount) {
                CreateAccountView()
                    .environmentObject(authManager)
            }
            .sheet(isPresented: $showingRecoverAccount) {
                RecoverAccountView()
                    .environmentObject(authManager)
            }
        }
    }

    private func handleLogin() {
        errorMessage = ""

        let success = authManager.login(username: username, password: password)

        if !success {
            errorMessage = "Incorrect username or password."
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
