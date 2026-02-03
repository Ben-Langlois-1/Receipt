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
    @State private var dailySpending = 0.0
    @State private var monthlySpending = 0.0
    @State private var yearlySpending = 0.0
    @FocusState private var amountIsFocused: Bool
    @Binding var showWelcomeScreen: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("Input daily, monthly, and yearly spending amounts")
                    {
                        TextField(
                            "Daily spending",
                            value: $dailySpending,
                            format: .currency(
                                code: Locale.current.currency?.identifier
                                    ?? "USD"
                            )
                        )

                        TextField(
                            "Monthly spending",
                            value: $monthlySpending,
                            format: .currency(
                                code: Locale.current.currency?.identifier
                                    ?? "USD"
                            )
                        )
                        TextField(
                            "Yearly spending",
                            value: $yearlySpending,
                            format: .currency(
                                code: Locale.current.currency?.identifier
                                    ?? "USD"
                            )
                        )
                    }
                    .focused($amountIsFocused)
                    .keyboardType(.decimalPad)
                    //Save goals
                    Button("Save goals") {
                        let goals = SpendingGoals(
                            daily: dailySpending,
                            monthly: monthlySpending,
                            yearly: yearlySpending
                        )
                        modelContext.insert(goals)
                        showWelcomeScreen = false

                    }
                    .font(Font.title3)
                    .padding(1)
                    .frame(maxWidth: .infinity)

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
