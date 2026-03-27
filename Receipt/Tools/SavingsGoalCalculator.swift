//
//  SavingsGoalCalculator.swift
//  Receipt
//
//  Created by Erica on 3/10/26.
//

import SwiftUI

struct SavingsGoalCalculatorView: View {
    
    @State private var goalAmount = ""
    @State private var currentSavings = ""
    @State private var monthlyContribution = ""
    @State private var months = ""
    
    var totalSaved: Double {
        let current = Double(currentSavings) ?? 0
        let monthly = Double(monthlyContribution) ?? 0
        let monthCount = Double(months) ?? 0
        return current + (monthly * monthCount)
    }
    
    var body: some View {
        Form {
            Section("Savings Goal Info") {
                
                TextField("Goal Amount", text: $goalAmount)
                    .keyboardType(.decimalPad)
                
                TextField("Current Savings", text: $currentSavings)
                    .keyboardType(.decimalPad)
                
                TextField("Monthly Contribution", text: $monthlyContribution)
                    .keyboardType(.decimalPad)
                
                TextField("Months", text: $months)
                    .keyboardType(.numberPad)
            }
            
            Section("Projected Savings") {
                Text(totalSaved,
                     format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            }
        }
        .navigationTitle("Savings Goal Calculator")
    }
}
#Preview {
   SavingsGoalCalculatorView()
}
// Added SavingsGoalCalculator tool //
