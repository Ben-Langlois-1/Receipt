import SwiftUI

struct RecoverAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    @State private var answer1 = ""
    @State private var answer2 = ""
    @State private var pin = ""

    @State private var errorMessage = ""
    @State private var recoveredUsername = ""
    @State private var showingRecoveredUsername = false
    @State private var showingResetPassword = false
    @State private var recoveryVerified = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("Recover Account")
                        .font(.largeTitle.bold())

                    Text("Answer your security questions or enter your recovery PIN.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // MARK: - Security Questions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Security Questions")
                            .font(.headline)

                        Text(authManager.recoveryQuestion1)
                            .font(.subheadline)

                        TextField("Answer 1", text: $answer1)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Text(authManager.recoveryQuestion2)
                            .font(.subheadline)

                        TextField("Answer 2", text: $answer2)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Button("Verify Answers") {
                            verifyAnswers()
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    Divider()

                    // MARK: - PIN Recovery
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recovery PIN")
                            .font(.headline)

                        SecureField("Enter PIN", text: $pin)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        Button("Verify PIN") {
                            verifyPin()
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    if recoveryVerified {
                        VStack(spacing: 12) {
                            Button("Show Username") {
                                recoveredUsername = authManager.savedUsername
                                showingRecoveredUsername = true
                            }

                            Button("Reset Password") {
                                showingResetPassword = true
                            }
                        }
                        .padding(.top)
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Recover Account")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Recovered Username", isPresented: $showingRecoveredUsername) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your username is: \(recoveredUsername)")
            }
            .sheet(isPresented: $showingResetPassword) {
                ResetPasswordView()
                    .environmentObject(authManager)
            }
        }
    }

    // MARK: - Logic

    private func verifyAnswers() {
        errorMessage = ""

        if authManager.verifySecurityAnswers(answer1: answer1, answer2: answer2) {
            recoveryVerified = true
        } else {
            errorMessage = "Incorrect answers."
        }
    }

    private func verifyPin() {
        errorMessage = ""

        if authManager.verifyRecoveryPin(pin) {
            recoveryVerified = true
        } else {
            errorMessage = "Incorrect PIN."
        }
    }
}

#Preview {
    RecoverAccountView()
        .environmentObject(AuthManager())
}
