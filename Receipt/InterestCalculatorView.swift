//
//  InterestView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/13/26.
//

import SwiftUI

struct InterestCalculatorView: View {
    @State private var amount = ""
    @State private var interest = 0.0
    @State private var term = ""
    @State private var selectedTimePeriod = "Months"
    @FocusState private var amountIsFocused: Bool
    @State private var isCompoundInterest = false

    private var timePeriods = ["Months", "Years"]

    var totalAmountSimpleInterest: Double {
        let termValue = Double(term) ?? 0
        let years: Double
        switch selectedTimePeriod {
        case "Months": years = termValue / 12
        case "Weeks": years = termValue / 52
        default: years = termValue
        }
        let interestOverTime = interest * (years / 100)
        return (Double(amount) ?? 0) * (1 + interestOverTime)

    }

    var totalAmountCompoundInterest: Double {
        let termValue = Double(term) ?? 0
        let years: Double
        let n: Double = 1.0  //Number of times interest is compounded per year (1 for annual, 12 for monthly, etc)
        switch selectedTimePeriod {
        case "Months": years = termValue / 12
        case "Weeks": years = termValue / 52
        default: years = termValue
        }
        let interestDividedByN = (1 + ((interest / 100) / n))
        let interestRaisedToN = pow(interestDividedByN, (n * years))
        return (Double(amount) ?? 0) * (interestRaisedToN)
    }

    var body: some View {
        Form {
            Section {
                TextField(
                    "Initial savings/investment amount",
                    text: $amount
                )
                .focused($amountIsFocused)
                .keyboardType(.decimalPad)
                Stepper(
                    "\(interest.formatted())%",
                    value: $interest,
                    in: 0...50,
                    step: 0.25
                )
                TextField(
                    "Term",
                    text: $term
                )
                .focused($amountIsFocused)
                .keyboardType(.decimalPad)
                Picker("Time period", selection: $selectedTimePeriod) {
                    ForEach(timePeriods, id: \.self) {
                        Text($0)
                    }
                }
            }

            Section {
                Toggle("Compound interest?", isOn: $isCompoundInterest)
                    .toggleStyle(.switch)

            }
            Section("Total value after \(term) \(selectedTimePeriod.lowercased())") {
                Text(
                    returnInterest(),
                    format: .currency(
                        code: Locale.current.currency?.identifier ?? "USD"
                    )
                )
            }
        }
        .navigationTitle("Interest Calculator")
        .toolbar {
            if amountIsFocused {
                Button("Done") {
                    amountIsFocused = false
                }
            }
        }
    }
    func returnInterest() -> Double {
        if isCompoundInterest {
            return totalAmountCompoundInterest
        } else {
            return totalAmountSimpleInterest
        }
    }
}

#Preview {
    InterestCalculatorView()
}
