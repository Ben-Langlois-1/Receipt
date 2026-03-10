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
        WindowGroup { MainView() }
            .modelContainer(container)
    }
}
