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
    var body: some Scene {
        WindowGroup {
            MainView()
        } .modelContainer(for: [SpendingGoals.self])
    }
}
