//
//  GoalsView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/4/26.
//

import SwiftData
import SwiftUI

struct GoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SpendingGoal.startDate) var goals: [SpendingGoal]
    @State private var editingAmount: String = ""
    @State private var selectedGoal: SpendingGoal?

    var body: some View {
        NavigationStack {
            Form {
                Section("Current Goals") {
                    ForEach(goals) { goal in
                        Button {
                            selectedGoal = goal
                            editingAmount = String(goal.targetAmount)
                        } label: {
                            HStack {
                                Text(
                                    "\(goal.frequency.rawValue.capitalized) Goal"
                                )
                                Spacer()
                                Text(
                                    "\(goal.targetAmount, format: .currency(code: "USD"))"
                                )
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                if let goalToEdit = selectedGoal {
                    Section(
                        "Update \(goalToEdit.frequency.rawValue.capitalized) Goal"
                    ) {
                        TextField("New Amount", text: $editingAmount)
                            .keyboardType(.decimalPad)

                        Button("Save Changes") {
                            updateGoal(goalToEdit)
                        }
                        .disabled(editingAmount.isEmpty)

                        Button("Cancel", role: .cancel) {
                            selectedGoal = nil
                        }
                    }
                }

            }

            .navigationTitle("Goals")
        }
    }

    func updateGoal(_ goal: SpendingGoal) {
        if let newAmount = Double(editingAmount) {
            goal.targetAmount = newAmount

            selectedGoal = nil
            editingAmount = ""
        }
    }
}

#Preview() {
    GoalsView()
}
