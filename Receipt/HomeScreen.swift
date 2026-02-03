//
//  HomeScreen.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/3/26.
//

import SwiftData
import SwiftUI

struct HomeScreen: View {
    @Query private var allGoals: [SpendingGoals]
    @State private var showWelcomeView = true

    //Find the most recent goals
    private var latestGoals: SpendingGoals? {
        allGoals.last
    }

    var body: some View {
        VStack {
            Text("Home screen content")
                .font(.title)
            Text("Goals count: \(allGoals.count)")
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
        .onAppear {
            // Show the welcome sheet only if there are no goals yet
            showWelcomeView = allGoals.isEmpty
        }
        .sheet(isPresented: $showWelcomeView) {
            WelcomeView(showWelcomeScreen: $showWelcomeView)
        }
    }

}

#Preview {
    HomeScreen()
}
