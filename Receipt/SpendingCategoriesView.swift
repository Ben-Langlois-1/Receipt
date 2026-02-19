//
//  SpendingCategories.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/16/26.
//

import SwiftData
import SwiftUI

struct SpendingCategoriesView: View {
    @Query var spendingCategories: [SpendingCategory]
    @Environment(\.modelContext) var modelContext
    
    func deleteCategory(_ indexSet: IndexSet) {
        for index in indexSet {
            let category = spendingCategories[index]
            modelContext.delete(category)
        }
    }
    
    var body: some View {
        NavigationStack {
            List{
                ForEach(spendingCategories) { category in
                    HStack {
                        Text("\(category.name)")
                    }
                }
                .onDelete(perform: deleteCategory)
                .navigationTitle("Spending Categories")
            }
        }
    }
}

#Preview {
    SpendingCategoriesView()
}
