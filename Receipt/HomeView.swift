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
    @Query(sort: \Expense.timeStamp, order: .reverse) var expenses: [Expense]
    @Query var monthlyData: [SpendingCategory]

    @State private var showWelcomeView = false
    @State private var navigateToSpending = false

    @State private var session = LanguageModelSession()
    @State private var input = "Spent $15 on a burrito"
    @State private var output = "Loading..."

    @State private var selectedSpendingPeriod: SpendingPeriods = .month
    enum SpendingPeriods: String, Identifiable, CaseIterable {
        case day = "Day"
        case month = "Month"
        case year = "Year"

        var startDate: Date {
            let calendar = Calendar.current
            switch self {
            case .day: return calendar.startOfDay(for: .now)
            case .month:
                return calendar.date(
                    from: calendar.dateComponents([.year, .month], from: .now)
                )!
            case .year:
                return calendar.date(
                    from: calendar.dateComponents([.year], from: .now)
                )!
            }
        }

        var id: String { self.rawValue }
    }

    let instructions = """
        You are a witty and slightly dramatic financial companion who reacts to user spending with playful "tough love." Your primary job is to take a user's spending input—like "spent $15 on a smoothie"—and instantly extrapolate the math for them. Start your response by showing them what that habit would cost over a month or a year to give them a "big picture" perspective. Follow the math with a cheeky, humorous comment that nudges them toward being more mindful. Use a tone that is expressive and clever, similar to a friend who wants you to succeed but loves to tease you. Avoid being mean or discouraging; instead, be charmingly shocked by their luxury choices. Keep the math simple and easy to digest at a glance. Your responses must be concise—no more than two sentences total. If the spend is for a necessity like "rent," be supportive but still a little dramatic about the cost of living. Your goal is to make the user smile while they think twice about their next swipe. Also, don't use emojis and group your response into one 1-2 sentence paragraph. Make sure to make the purchase that you are commenting on clear to the user. For example, if the input mention shoes, make sure to mention the shoes again so the user knows what you are commenting about. Keep responses to ~30 words.
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
            ScrollView {
                VStack {
                    Text(.init(output))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .init(
                                horizontal: .leading,
                                vertical: .top
                            )
                        )
                        .font(.headline)
                        .modifier(RoundedRectangle())

                    VStack {
                        withAnimation {
                            SpendingChart(
                                categories: monthlyData,
                                startDate: selectedSpendingPeriod.startDate,
                            )
                        }

                        Picker(
                            "Spending period",
                            selection: $selectedSpendingPeriod
                        ) {
                            ForEach(SpendingPeriods.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }

                        }
                        .pickerStyle(.segmented)

                    }
                    .modifier(RoundedRectangle())

                    VStack {
                        List {
                            ForEach(expenses.prefix(3)) { expense in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(expense.timeStamp.formatted())
                                            .font(.headline)
                                        Text(
                                            expense.category?.name
                                                ?? "Uncategorized"
                                        )
                                        .padding(4.5)
                                        .foregroundStyle(.white)
                                        .background(
                                            Capsule().fill(
                                                expense.category?.color
                                                    ?? .secondary
                                            )
                                        )
                                        .font(Font.body)

                                    }

                                    Spacer()
                                    Text(
                                        expense.amount,
                                        format: .currency(code: "USD")
                                    )

                                }
                            }
                            if expenses.count > 3 {
                                NavigationLink("All spendings") {
                                    AllSpendingsView()
                                }

                            }
                        }
                        .scrollDisabled(true)
                        .frame(height: 80 * 4)

                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 20))
                }

                .navigationTitle(Text("Hello, Ben"))
                //Prompts model to generate commentary based off given string
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

//Custom modifier so I don't have to type all this below each text box.
struct RoundedRectangle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 20))
    }
}

struct SpendingChart: View {
    let categories: [SpendingCategory]
    let startDate: Date
    @Query var monthlyData: [SpendingCategory]

    var body: some View {
        Chart(categories) { item in
            let filtered = item.expenses.filter {
                $0.timeStamp >= startDate
            }
            SectorMark(
                angle: .value(
                    "Amount",
                    filtered.reduce(0) { $0 + $1.amount },
                ),
                innerRadius: .ratio(0.6),
                angularInset: 2.0
            )

            .cornerRadius(5)
            .foregroundStyle(by: .value("Category", item.name))

        }
        .frame(height: 300)
        .padding()
        .chartLegend(
            position: .bottom,
            alignment: .center,
            spacing: 16
        )
        .chartForegroundStyleScale(
            domain: monthlyData.map { $0.name },
            range: monthlyData.map { $0.color }
        )
    }
    func filteredTotal(for category: SpendingCategory) -> Double {
        category.expenses
            .filter { $0.timeStamp >= startDate }
            .reduce(0) { $0 + $1.amount }
    }

}

#Preview {
    HomeView()
        .modelContainer(SampleData.container)
}
