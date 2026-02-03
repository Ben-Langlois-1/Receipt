//
//  SpendingGoals.swift
//  Receipt
//
//  Created by Benjamin Langlois on 1/28/26.
//

import Foundation
import SwiftData

@Model
class SpendingGoals {
    var daily: Double
    var monthly: Double
    var yearly: Double
    

    init(daily: Double, monthly: Double, yearly: Double) {
        self.daily = daily
        self.monthly = monthly
        self.yearly = yearly
    }
}
