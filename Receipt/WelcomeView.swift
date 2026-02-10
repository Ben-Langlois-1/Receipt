//
//  WelcomeView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 1/28/26.
//

import SwiftData
import SwiftUI

struct WelcomeView: View {
    @Environment(\.modelContext) var modelContext
    @State private var dailySpending = ""
    @State private var monthlySpending = ""
    @State private var yearlySpending = ""
    @FocusState private var amountIsFocused: Bool
    @Binding var showWelcomeScreen: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Input spending goals")
                    {
                        TextField(
                            "Daily spending",
                            text: $dailySpending
                        )

                        TextField(
                            "Monthly spending",
                            text: $monthlySpending
                            )
                        
                        TextField(
                            "Yearly spending",
                            text: $yearlySpending
                            )
                    }
                    .focused($amountIsFocused)
                    .keyboardType(.decimalPad)
                    //Save goals
                    Button("Save goals") {
                        let daily = Double(dailySpending) ?? 0.0
                        let monthly = Double(monthlySpending) ?? 0.0
                        let yearly = Double(yearlySpending) ?? 0.0
                        
                        let goals = SpendingGoals(
                            daily: daily,
                            monthly: monthly,
                            yearly: yearly
                        )
                        modelContext.insert(goals)
                        showWelcomeScreen = false

                    }
                    .font(Font.title3)
                    .padding(1)
                    .frame(maxWidth: .infinity)
                    .disabled(Double(dailySpending) == 0.0 || Double(monthlySpending) == 0.0 || Double(yearlySpending) == 0.0)

                }
                .navigationTitle("Welcome to Receipt!")
                .toolbar {
                    if amountIsFocused {
                        Button("Done") {
                            amountIsFocused = false
                        }
                    }
                }

            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}

