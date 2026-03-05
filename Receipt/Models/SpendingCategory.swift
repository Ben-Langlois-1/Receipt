//
//  SpendingCategories.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/15/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class SpendingCategory: Identifiable {
    var id = UUID()
    var name: String
    var colorHex: String
    //The list of expenses that are attached to this category.
    //Deleting a category will also delete all expenses associated with it.
    @Relationship(deleteRule: .cascade) var expenses = [Expense]()

    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.toHex() }
    }

    init(name: String, color: Color) {
        self.name = name
        self.colorHex = color.toHex()
    }
    
}

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "#%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
    
    init(hex: String) {
            let hex = hex.trimmingCharacters(
                in: CharacterSet.alphanumerics.inverted
            )
            var int: UInt64 = 0
            Scanner(string: hex).scanHexInt64(&int)
            let r = Double((int >> 16) & 0xFF) / 255.0
            let g = Double((int >> 8) & 0xFF) / 255.0
            let b = Double(int & 0xFF) / 255.0
            self.init(red: r, green: g, blue: b)
        }

}
