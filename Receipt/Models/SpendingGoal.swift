//
//  SpendingGoals.swift
//  Receipt
//
//  Created by Benjamin Langlois on 1/28/26.
//

import Foundation
import SwiftData

enum GoalFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { self.rawValue }
}

@Model
final class SpendingGoal {
    var targetAmount: Double
    var frequency: GoalFrequency
    var startDate: Date
    var category: SpendingCategory?

    init(targetAmount: Double = 0.0, frequency: GoalFrequency = .monthly, startDate: Date = .now) {
        self.targetAmount = targetAmount
        self.frequency = frequency
        self.startDate = startDate
    }
}
