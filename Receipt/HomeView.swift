//
//  HomeView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/3/26.
//

import Charts
import FoundationModels
import SwiftData
import SwiftUI

struct HomeView: View {
    @Query var allGoals: [SpendingGoal]
    @State private var showWelcomeView = false
    @State private var navigateToSpending = false
    @State private var session = LanguageModelSession()
    @State private var input = "Spent $15 on a burrito"
    @State private var output = "Loading..."

    let instructions = """
        You are a witty and slightly dramatic financial companion who reacts to user spending with playful "tough love." Your primary job is to take a user's spending input—like "spent $15 on a smoothie"—and instantly extrapolate the math for them. Start your response by showing them what that habit would cost over a month or a year to give them a "big picture" perspective. Follow the math with a cheeky, humorous comment that nudges them toward being more mindful. Use a tone that is expressive and clever, similar to a friend who wants you to succeed but loves to tease you. Avoid being mean or discouraging; instead, be charmingly shocked by their luxury choices. Keep the math simple and easy to digest at a glance. Your responses must be concise—no more than two sentences total. If the spend is for a necessity like "rent," be supportive but still a little dramatic about the cost of living. Your goal is to make the user smile while they think twice about their next swipe. Also, don't use emojis and group your response into one 1-2 sentence paragraph. Make sure to make the purchase that you are commenting on clear to the user. For example, if the input mention shoes, make sure to mention the shoes again so the user knows what you are commenting about.
        """

    func generateCommentary() {
        session = LanguageModelSession(instructions: instructions)

        Task {
            let response = try await session.respond(to: input)
            output = response.content
        }
    }

    var body: some View {
        NavigationStack {
            VStack {

                Text(.init(output))
                    .font(.headline)
                    .padding()
                    .modifier(RoundedRectangle())

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
            .navigationTitle(Text("Hello, Ben"))
            .onAppear {
                generateCommentary()
            }
            .padding()
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
            showWelcomeView = allGoals.isEmpty
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
