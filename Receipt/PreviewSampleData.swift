//
//  PreviewSampleData.swift
//  Receipt
//
//  Created by Benjamin Langlois on 3/4/26.
//

import SwiftData
import SwiftUI

/*
 This file is for sample purposes only. It's only function is to provide example data in the canvas.
 This eliminates the need to run the app everytime someone want's to see changes that relate to models.
 */

@MainActor
struct SampleData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Expense.self,
            SpendingCategory.self,
            SpendingGoal.self,
            configurations: config
        )
        //Example expenses
        let expenses = [
            Expense(
                amount: 100,
                timeStamp: Date(),
                category: .init(name: "Food", color: .blue)
            ),
            Expense(
                amount: 1000,
                timeStamp: Date(),
                category: .init(name: "Rent", color: .red)
            ),
            Expense(
                amount: 25,
                timeStamp: Date(),
                category: .init(name: "Gym", color: .green)
            ),
        ]
        expenses.forEach { container.mainContext.insert($0) }

        //Example spending goals
        let goals = [
            SpendingGoal(
                targetAmount: 20,
                frequency: .daily,
                startDate: .now
            ),
            SpendingGoal(
                targetAmount: 350,
                frequency: .monthly,
                startDate: .now
            ),
            SpendingGoal(
                targetAmount: 4500,
                frequency: .yearly,
                startDate: .now
            ),
        ]
        goals.forEach { container.mainContext.insert($0) }
        return container
    }()

}
