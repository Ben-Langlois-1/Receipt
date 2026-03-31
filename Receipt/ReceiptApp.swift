//
//  ReceiptApp.swift
//  Receipt
//
//  Created by Benjamin Langlois on 1/28/26.
//

import SwiftData
import SwiftUI

@main
struct ReceiptApp: App {
    @AppStorage("preferDarkMode") private var preferDarkMode: Bool = false
    @StateObject private var authManager = AuthManager()

    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(
            for: Expense.self,
            SpendingCategory.self,
            SpendingGoal.self,
            configurations: config
        )
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    MainView()
                        .preferredColorScheme(preferDarkMode ? .dark : .light)
                        .environmentObject(authManager)

                } else {
                    LoginView()
                        .preferredColorScheme(preferDarkMode ? .dark : .light)
                        .environmentObject(authManager)
                }
            }
        }
        .modelContainer(container)
    }
}
