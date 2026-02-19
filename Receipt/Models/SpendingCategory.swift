//
//  SpendingCategories.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/15/26.
//

import Foundation
import SwiftData

@Model
final class SpendingCategory {
    var name: String
    var color: String
    //The list of expenses that are attached to this category.
    //Deleting a category will also delete all expenses associated with it.
    @Relationship(deleteRule: .cascade) var expenses = [Expense]()
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
    }
    
}
