//
//  AllSpendingsView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/25/26.
//

import SwiftData
import SwiftUI

struct AllSpendingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.timeStamp, order: .reverse) var expenses: [Expense]

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.timeStamp.formatted())
                                .font(.headline)
                            Text("Food")
                        }

                        Spacer()
                        Text(
                            expense.amount,
                            format: .currency(code: "USD")
                        )
                    }

                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("All expenses")
            .toolbar {
                EditButton()
            }
        }
    }

    func deleteCategory(_ indexSet: IndexSet) {
        for index in indexSet {
            let expense = expenses[index]
            modelContext.delete(expense)
        }
    }
}

#Preview {
    AllSpendingsView()
        .modelContainer(SampleData.container)
}
