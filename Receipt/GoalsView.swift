//
//  GoalsView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/4/26.
//

import SwiftUI
import SwiftData


struct GoalsView: View {
    @Query private var allGoals: [SpendingGoals]
    
    //Find the most recent goals
    private var latestGoals: SpendingGoals? {
        allGoals.last
    }
    var body: some View {
        NavigationStack {
            Text("Hello, Goals!")
                .font(Font.largeTitle.bold())
                .navigationTitle(Text("Goals"))
            if let latest = latestGoals {
                Text(
                    "Daily Goal: \(latest.daily, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))"
                )
                Text(
                    "Monthly Goal: \(latest.monthly, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))"
                )
                Text(
                    "Yearly Goal: \(latest.yearly, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))"
                )
            } else {
                Text("No goals saved yet.")
            }

        }
    }
}

#Preview {
    GoalsView()
}
