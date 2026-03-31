import Foundation
import SwiftUI
import Combine
import LocalAuthentication
import Security

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasStoredPassword = false
    @Published var biometricsAvailable = false
    @Published var biometricsEnabled = false
    @Published var savedUsername = ""
    @Published var recoveryQuestion1 = ""
    @Published var recoveryQuestion2 = ""

    private let recoveryQuestion1Key = "recoveryQuestion1"
    private let recoveryAnswer1Key = "recoveryAnswer1"
    private let recoveryQuestion2Key = "recoveryQuestion2"
    private let recoveryAnswer2Key = "recoveryAnswer2"
    private let recoveryPinKey = "recoveryPin"

    private let service = "com.receipt.app"
    private let account = "localUserPassword"
    private let biometricsKey = "biometricsEnabled"
    private let usernameKey = "savedUsername"

    init() {
        loadUsername()
        loadRecoveryData()
        checkPasswordExists()
        checkBiometricsAvailability()
        biometricsEnabled = UserDefaults.standard.bool(forKey: biometricsKey)
    }

    func loadUsername() {
        savedUsername = UserDefaults.standard.string(forKey: usernameKey) ?? ""
    }

    func saveUsername(_ username: String) {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        savedUsername = trimmed
        UserDefaults.standard.set(trimmed, forKey: usernameKey)
    }

    func loadRecoveryData() {
        recoveryQuestion1 = UserDefaults.standard.string(forKey: recoveryQuestion1Key) ?? ""
        recoveryQuestion2 = UserDefaults.standard.string(forKey: recoveryQuestion2Key) ?? ""
    }

    func saveRecoveryData(
        question1: String,
        answer1: String,
        question2: String,
        answer2: String,
        pin: String
    ) {
        let normalizedAnswer1 = normalize(answer1)
        let normalizedAnswer2 = normalize(answer2)
        let trimmedPin = pin.trimmingCharacters(in: .whitespacesAndNewlines)

        UserDefaults.standard.set(question1, forKey: recoveryQuestion1Key)
        UserDefaults.standard.set(normalizedAnswer1, forKey: recoveryAnswer1Key)
        UserDefaults.standard.set(question2, forKey: recoveryQuestion2Key)
        UserDefaults.standard.set(normalizedAnswer2, forKey: recoveryAnswer2Key)
        UserDefaults.standard.set(trimmedPin, forKey: recoveryPinKey)

        recoveryQuestion1 = question1
        recoveryQuestion2 = question2
    }

    func verifySecurityAnswers(answer1: String, answer2: String) -> Bool {
        let savedAnswer1 = UserDefaults.standard.string(forKey: recoveryAnswer1Key) ?? ""
        let savedAnswer2 = UserDefaults.standard.string(forKey: recoveryAnswer2Key) ?? ""

        return normalize(answer1) == savedAnswer1 &&
               normalize(answer2) == savedAnswer2
    }

    func verifyRecoveryPin(_ pin: String) -> Bool {
        let savedPin = UserDefaults.standard.string(forKey: recoveryPinKey) ?? ""
        let trimmedPin = pin.trimmingCharacters(in: .whitespacesAndNewlines)
        return !savedPin.isEmpty && trimmedPin == savedPin
    }

    func createAccount(
        username: String,
        password: String,
        question1: String,
        answer1: String,
        question2: String,
        answer2: String,
        pin: String
    ) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPin = pin.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedUsername.isEmpty,
              !trimmedPassword.isEmpty,
              !question1.isEmpty,
              !answer1.isEmpty,
              !question2.isEmpty,
              !answer2.isEmpty,
              !trimmedPin.isEmpty else {
            return false
        }

        let passwordSaved = savePassword(trimmedPassword)

        if passwordSaved {
            saveUsername(trimmedUsername)
            saveRecoveryData(
                question1: question1,
                answer1: answer1,
                question2: question2,
                answer2: answer2,
                pin: trimmedPin
            )
        }

        return passwordSaved
    }

    func login(username: String, password: String) -> Bool {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedUsername == savedUsername else { return false }

        let validPassword = validatePassword(password)
        if validPassword {
            isAuthenticated = true
        }
        return validPassword
    }

    func checkPasswordExists() {
        hasStoredPassword = readPassword() != nil
    }

    func checkBiometricsAvailability() {
        let context = LAContext()
        var error: NSError?
        biometricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func savePassword(_ password: String) -> Bool {
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        deletePassword()

        let data = Data(password.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        let success = status == errSecSuccess

        if success {
            hasStoredPassword = true
        }

        return success
    }

    func validatePassword(_ password: String) -> Bool {
        guard let savedPassword = readPassword() else { return false }
        return password == savedPassword
    }

    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password Instead"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock Receipt"
            )

            if success {
                isAuthenticated = true
            }

            return success
        } catch {
            return false
        }
    }

    func logout() {
        isAuthenticated = false
    }

    func setBiometricsEnabled(_ enabled: Bool) {
        biometricsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: biometricsKey)
    }

    func changePassword(currentPassword: String, newPassword: String) -> Bool {
        guard validatePassword(currentPassword) else { return false }
        return savePassword(newPassword)
    }

    func resetPassword(newPassword: String) -> Bool {
        let trimmed = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return false
        }

        return savePassword(trimmed)
    }

    func resetPasswordAfterRecovery(newPassword: String) -> Bool {
        let trimmed = newPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return false
        }

        return savePassword(trimmed)
    }

    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func readPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }

    private func deletePassword() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
