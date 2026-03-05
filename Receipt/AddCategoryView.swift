//
//  SpendingCategories.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/16/26.
//

import SwiftData
import SwiftUI

struct AddCategoryView: View {
    @Query var spendingCategories: [SpendingCategory]
    @Environment(\.modelContext) var modelContext
    @State private var newCategoryName: String = ""
    @State private var newCategoryColor: Color = .blue
    @Environment(\.dismiss) var dismiss

    init(categoryName: String = "", categoryColor: Color = .gray) {
        newCategoryName.self = categoryName
        newCategoryColor.self = categoryColor
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Add new category") {
                    TextField("Category name", text: $newCategoryName)
                    ColorPicker(
                        "Color",
                        selection: $newCategoryColor,
                        supportsOpacity: false
                    )

                    Button("Add") {
                        dismiss()
                        let newCategory = SpendingCategory(
                            name: newCategoryName,
                            color: newCategoryColor
                        )
                        modelContext.insert(newCategory)
                        withAnimation {
                            newCategoryName = ""
                        }

                    }
                }
            }
        }
    }
}
#Preview {
    AddCategoryView()
        .modelContainer(SampleData.container)
}
