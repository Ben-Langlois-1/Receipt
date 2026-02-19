//
//  Expense.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/15/26.
//

import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var timeStamp: Date
    var category: SpendingCategory?
    
    init(amount: Double, timeStamp: Date, category: SpendingCategory? = nil) {
        self.amount = amount
        self.timeStamp = timeStamp
        self.category = category
        
    }
}
