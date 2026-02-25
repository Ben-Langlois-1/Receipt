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
    @Query(sort: \SpendingCategory.name) var categories: [SpendingCategory]

    @State private var editingAmount: String = ""
    @State private var newCategory: SpendingCategory?
    @State private var selectedGoal: SpendingGoal?
    @State private var selectedCategory: SpendingCategory?
    @State private var showAddCategoryView = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Current Goals") {
                    ForEach(goals) { goal in
                        Button {
                            withAnimation {
                                selectedGoal = goal
                                editingAmount = String(goal.targetAmount)

                            }
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
                                    .foregroundStyle(Color.gray)
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
                Section("Spending Categories") {
                    ForEach(categories) { category in
                        Button {
                            withAnimation {
                                //See comment on line ~105
                                //showAddCategoryView.toggle()
                                selectedCategory = category
                                editingAmount = ""
                            }
                        } label: {
                            HStack {
                                Text(category.name)
                                Spacer()
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                            }
                        }

                    }
                    //TODO: addd confirmation message before deletion
                    .onDelete(perform: deleteCategory(_:))
                    

                }

                if categories.isEmpty {
                    Button {
                        showAddCategoryView.toggle()
                    } label: {
                        HStack {
                            Text("No spending categories added yet")
                                .foregroundStyle(.black)
                            Spacer()
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .padding(6)
                                .background(
                                    Circle().fill(Color.blue)
                                )
                        }
                    }

                } else {
                    Button {
                        withAnimation {
                            showAddCategoryView.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(
                                Circle().fill(Color.blue)
                            )
                    }
                }
                /*
                 TODO: This works but is not pretty. Ideally, editing the category would call AddCategoryView with the information from that category already populated.
                 */
                if let categoryToEdit = selectedCategory {
                    Section(
                        "Update \(categoryToEdit.name) Category"
                    ) {
                        TextField("New name", text: $editingAmount)

                        Button("Save Changes") {
                            updateCategory(categoryToEdit)
                        }
                        .disabled(editingAmount.isEmpty)

                        Button("Cancel", role: .cancel) {
                            selectedCategory = nil
                        }
                    }
                }

            }
            .navigationTitle("Goals")
            .sheet(isPresented: $showAddCategoryView) {
                AddCategoryView()
            }

        }
    }

    func updateGoal(_ goal: SpendingGoal) {
        if let newAmount = Double(editingAmount) {
            goal.targetAmount = newAmount

            selectedGoal = nil
            editingAmount = ""
        }
    }

    func updateCategory(_ category: SpendingCategory) {
        category.name = editingAmount

        selectedCategory = nil
        editingAmount = ""
    }

    func deleteCategory(_ indexSet: IndexSet) {
        for index in indexSet {
            let category = categories[index]
            modelContext.delete(category)
        }
    }
}

#Preview() {
    GoalsView()
}
