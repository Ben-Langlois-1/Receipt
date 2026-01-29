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
    var daily: String
    var monthly: String
    var yearly: String
    

    init(daily: String, monthly: String, yearly: String) {
        self.daily = daily
        self.monthly = monthly
        self.yearly = yearly
    }
}
