//
//  HomeView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/3/26.
//

import Charts
import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var allGoals: [SpendingGoals]
    @State private var showWelcomeView = false
    @State private var navigateToSpending = false

    //Find the most recent goals from local storage. 
    private var latestGoals: SpendingGoals? {
        allGoals.last
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(
                    "If I had to guess? You're trying to recreate the '08 crash in your own bank account."
                )
                .font(.headline)
                .padding()
                .modifier(RoundedRectangle())
                .navigationTitle(Text("Hello, Ben"))
                VStack {
                    Chart(monthlyData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.6),
                            angularInset: 2.0
                        )

                        .cornerRadius(5)
                        .foregroundStyle(item.color)
                        .foregroundStyle(
                            by: .value(
                                "Category",
                                "\(item.category) $\(Int(item.amount))"
                            )
                        )

                    }
                    .frame(height: 300)
                    .chartLegend(alignment: .center, spacing: 40)
                    .padding()
                    .modifier(RoundedRectangle())

                }
            }
            //Currently can show TWO "confirm" buttons. Needs to be changed.
            //Also, why is there a white border around the page?
            .toolbar {
                Button("Add spending", systemImage: "plus") {
                    navigateToSpending = true
                }
            }
            .navigationDestination(isPresented: $navigateToSpending) {
                AddSpendingView()
            }
            
            Spacer()
            Spacer()
        }
        
        .onAppear {
            // Show the welcome sheet only if there are no goals yet
            //showWelcomeView = allGoals.isEmpty
        }
        .sheet(isPresented: $showWelcomeView) {
            WelcomeView(showWelcomeScreen: $showWelcomeView)
        }
    }
}

struct MonthlyExpense: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let color: Color
}


let monthlyData: [MonthlyExpense] = [
    .init(category: "Food", amount: 300, color: .orange),
    .init(category: "Rent", amount: 1200, color: .blue),
    .init(category: "Gym", amount: 100, color: .green),
    .init(category: "Misc", amount: 250, color: .purple),
]

//Custom modifier so I don't have to type all this below each text box.
struct RoundedRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    HomeView()
}
