//
//  SettingsView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/4/26.
//

import SwiftUI

enum Personalities: String, CaseIterable, Identifiable {
    case mean, normal, nice, smart
    var id: Self { self }

    var prompt: String {
        ChatController.personalityPrompts[self]
            ?? "You are a helpful assistant."
    }

    var displayName: String {
        rawValue.capitalized
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("preferDarkMode") private var preferDarkMode: Bool = false
    @AppStorage("chatBotPersonality") private var chatBotPersonality:
        Personalities = .normal

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle(isOn: $preferDarkMode) {
                        Text("Enable dark mode")
                    }
                }
                Section("ChatBot Personality") {
                    Picker("Personality", selection: $chatBotPersonality) {
                        ForEach(Personalities.allCases) { personality in
                            Text(personality.displayName).tag(personality)
                        }
                    }
                }
                Section("Security") {
                    if authManager.biometricsAvailable {
                        Toggle(
                            "Enable Face ID / Touch ID",
                            isOn: Binding(
                                get: { authManager.biometricsEnabled },
                                set: { authManager.setBiometricsEnabled($0) }
                            )
                        )
                    } else {
                        Text("Biometrics not available on this device.")
                            .foregroundStyle(.secondary)
                    }

                    Button("Log Out", role: .destructive) {
                        authManager.logout()
                    }
                }

            }

            .navigationTitle(Text("Settings"))
        }

    }
}

#Preview {
    SettingsView()
}
