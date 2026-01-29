//
//  WelcomeView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 1/28/26.
//

import SwiftData
import SwiftUI

//struct to present input box to save spending amount (clean's up code)
struct GoalField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal, 10)
    }
}

struct WelcomeView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var allGoals: [SpendingGoals]
    @State private var dailySpending: String = ""
    @State private var monthlySpending: String = ""
    @State private var yearlySpending: String = ""
    @State private var showSavedMessage = false
    
    //Find the most recent goals
    private var latestGoals: SpendingGoals? {
        allGoals.last
    }
    
    var body: some View {
        if let latest = latestGoals {
              Text("Daily Goals: \(latest.daily)")
          } else {
              Text("No goals saved yet.")
          }
        
        VStack {
            Text("Welcome to Receipt!")
                .font(Font.largeTitle.bold())
                .padding(10)
            Text(
                "To get started, please input your daily, monthly, and yearly spending goal. Don't worry, you can always change these later!"
            )
            .padding(10)
            //Save each spending amount for the respective time period
            GoalField(title: "Daily spending", text: $dailySpending)
            GoalField(title: "Monthly spending", text: $monthlySpending)
            GoalField(title: "Yearly spending", text: $yearlySpending)
            
            //Save goals. Can't verify that they have been saved yet.
            //TODO: see saved goals
            Button("Save goals") {
                let goals = SpendingGoals(
                    daily: dailySpending,
                    monthly: monthlySpending,
                    yearly: yearlySpending
                )
                modelContext.insert(goals)
                
                // Show confirmation message
                showSavedMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showSavedMessage = false
                }
            }
            
            if showSavedMessage {
                Text("Goals saved!")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
            
        }
    }
}

#Preview {
    WelcomeView()
}
