//
//  AddSpendingView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/12/26.
//

import SwiftData
import SwiftUI

struct AddSpendingView: View {
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [Expense]
    @Query(sort: \SpendingCategory.name) var categories: [SpendingCategory]
    @State var expense: Expense?

    @State private var amountSpent: String = ""
    @State private var categorySpentOn: SpendingCategory?
    @State private var date = Date()

    @FocusState private var amountIsFocused: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section {
                TextField("Amount spent", text: $amountSpent)
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                Picker("Spending Category", selection: $categorySpentOn) {
                    ForEach(categories) { category in
                        Text(category.name).tag(Optional(category))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onAppear {
                    categorySpentOn = categories.first
                }
            }
            Section("When did you spend this?") {
                DatePicker(
                    "Date spent?",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .labelsHidden()
            }

        }

        .navigationTitle("Add an entry")
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                if amountIsFocused {
                    Button("Done") {
                        amountIsFocused = false
                    }
                } else {
                    Button("Done", systemImage: "checkmark") {
                        let newExpense = Expense(
                                amount: Double(amountSpent) ?? 0,
                                timeStamp: date
                            )
                            newExpense.category = categorySpentOn
                            modelContext.insert(newExpense)
                            dismiss()
                        }
                    }
                }
            }
        }
    }


#Preview {
    AddSpendingView()
        .modelContainer(SampleData.container)
}
