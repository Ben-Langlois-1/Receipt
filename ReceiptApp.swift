//
//  ReceiptApp.swift
//  Receipt
//
//  Created by Benjamin Langlois on 1/28/26.
//

import SwiftUI
import SwiftData

@main
struct ReceiptApp: App {
    @Query var destinations: [SpendingGoals]
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        } .modelContainer(for: SpendingGoals.self)
    }
}
