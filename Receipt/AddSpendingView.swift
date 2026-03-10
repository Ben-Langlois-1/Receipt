//
//  AddSpendingView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/12/26.
//

import SwiftUI

struct AddSpendingView: View {
    @State private var amountSpent: String = ""
    @State private var spendingCategorys = ["Food", "Rent", "Gym", "Misc"]
    @State private var categorySpentOn = "Food"
    @State private var date = Date()
    @FocusState private var amountIsFocused: Bool

    var body: some View {
        Form {
            Section {
                TextField("Amount spent", text: $amountSpent)
                    .keyboardType(.decimalPad)
                    .focused($amountIsFocused)
                Picker("Spending Category", selection: $categorySpentOn) {
                    ForEach(spendingCategorys, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())

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
                        //Some action here.
                    }
                }
            }
        }

    }
}

#Preview {
    AddSpendingView()
}
