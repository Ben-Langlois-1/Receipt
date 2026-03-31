import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var enableBiometrics = true
    @State private var showPassword = false

    @State private var question1 = "What city were you born in?"
    @State private var answer1 = ""
    @State private var question2 = "What was your first pet’s name?"
    @State private var answer2 = ""
    @State private var recoveryPin = ""
    @State private var showRecoveryPin = false

    private let questionOptions = [
        "What city were you born in?",
        "What was your first pet’s name?",
        "What was the name of your elementary school?",
        "What is your mother’s maiden name?",
        "What was your childhood nickname?"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Create Account")
                        .font(.largeTitle.bold())

                    Text("Set up a username, password, recovery questions, and a recovery PIN to protect your receipt data.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

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

                        passwordField(
                            title: "Password",
                            text: $password,
                            isVisible: $showPassword
                        )

                        passwordField(
                            title: "Confirm Password",
                            text: $confirmPassword,
                            isVisible: $showPassword
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Security Question 1")
                                .font(.headline)

                            Picker("Security Question 1", selection: $question1) {
                                ForEach(questionOptions, id: \.self) { question in
                                    Text(question).tag(question)
                                }
                            }
                            .pickerStyle(.menu)

                            TextField("Answer 1", text: $answer1)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Security Question 2")
                                .font(.headline)

                            Picker("Security Question 2", selection: $question2) {
                                ForEach(questionOptions, id: \.self) { question in
                                    Text(question).tag(question)
                                }
                            }
                            .pickerStyle(.menu)

                            TextField("Answer 2", text: $answer2)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recovery PIN")
                                .font(.headline)

                            HStack {
                                Group {
                                    if showRecoveryPin {
                                        TextField("Recovery PIN", text: $recoveryPin)
                                            .keyboardType(.numberPad)
                                    } else {
                                        SecureField("Recovery PIN", text: $recoveryPin)
                                            .keyboardType(.numberPad)
                                    }
                                }

                                Button {
                                    showRecoveryPin.toggle()
                                } label: {
                                    Image(systemName: showRecoveryPin ? "eye.slash" : "eye")
                                        .foregroundStyle(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }

                        if authManager.biometricsAvailable {
                            Toggle("Enable Face ID / Touch ID", isOn: $enableBiometrics)
                        }
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button("Create Account") {
                        createAccount()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Account")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func passwordField(title: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .textContentType(.password)
                } else {
                    SecureField(title, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .textContentType(.password)
                }
            }

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }

    private func createAccount() {
        errorMessage = ""

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer1 = answer1.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer2 = answer2.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPin = recoveryPin.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty else {
            errorMessage = "Username cannot be empty."
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }

        guard question1 != question2 else {
            errorMessage = "Choose two different security questions."
            return
        }

        guard !trimmedAnswer1.isEmpty, !trimmedAnswer2.isEmpty else {
            errorMessage = "Both security answers are required."
            return
        }

        guard !trimmedPin.isEmpty else {
            errorMessage = "Recovery PIN cannot be empty."
            return
        }

        guard trimmedPin.count >= 4 && trimmedPin.count <= 6 else {
            errorMessage = "Recovery PIN must be 4 to 6 digits."
            return
        }

        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: trimmedPin)) else {
            errorMessage = "Recovery PIN must contain only numbers."
            return
        }

        let created = authManager.createAccount(
            username: username,
            password: password,
            question1: question1,
            answer1: answer1,
            question2: question2,
            answer2: answer2,
            pin: recoveryPin
        )

        if created {
            authManager.setBiometricsEnabled(enableBiometrics)
            authManager.isAuthenticated = true
            dismiss()
        } else {
            errorMessage = "Could not create account."
        }
    }
}

#Preview {
    CreateAccountView()
        .environmentObject(AuthManager())
}
