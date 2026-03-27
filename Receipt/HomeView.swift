//
//  HomeView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/3/26.
//

import Charts
import OpenAI
import SwiftData
import SwiftUI

struct HomeView: View {
    // MARK: Properties
    @Query var allGoals: [SpendingGoal]
    @Query(sort: \Expense.timeStamp, order: .reverse) var expenses: [Expense]
    @Query var monthlyData: [SpendingCategory]

    @State private var showWelcomeView = false
    @State private var navigateToSpending = false

    @StateObject var chatController: ChatController = .init()
    @State var userText: String = ""
    @State var message: Message = Message(content: "", isUser: true)

    @State private var selectedSpendingPeriod: SpendingPeriods = .month

    //MARK: view body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let reply = chatController.messages.last(where: { $0.isUser == false }) {
                            Text(reply.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .modifier(RoundedRectangle())
                        } else {
                            ProgressView()
                        }
                    }

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
                                .listRowBackground(
                                    Color(UIColor.secondarySystemBackground)
                                )
                            }
                            if expenses.count > 3 {
                                NavigationLink("All spendings") {
                                    AllSpendingsView()
                                }
                                .listRowBackground(
                                    Color(UIColor.secondarySystemBackground)
                                )
                            }
                        }
                        .scrollDisabled(true)
                        .scrollContentBackground(.hidden)
                        .frame(height: 80 * 4)

                    }

                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 20))
                }
            }
            .padding()
            .navigationTitle(Text("Hello, Ben"))
            .toolbar {
                Button("Add spending", systemImage: "plus") {
                    navigateToSpending = true
                }
            }
            .navigationDestination(isPresented: $navigateToSpending) {
                AddSpendingView()
            }
        }
        .onAppear {
            // Show the welcome sheet only if there are no goals yet
            showWelcomeView = allGoals.isEmpty
            let amount = expenses.last?.amount ?? 0
            let formatted = amount.formatted(
                .currency(code: Locale.current.currency?.identifier ?? "USD")
            )
            userText =
                "Critique my most recent spending: I spent \(expenses.last?.amount != nil ? formatted : "unknown") on \(expenses.last?.timeStamp.formatted(date: .numeric, time: .shortened) ?? "unknown")"
            sendMessage()
        }
        .sheet(isPresented: $showWelcomeView) {
            WelcomeView(showWelcomeScreen: $showWelcomeView)
        }
    }
    //MARK: Functions housed in HomeView Struct
    func sendMessage() {
        let trimmed = userText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty { return }

        chatController.sendNewMessage(content: trimmed)
    }

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
}

//MARK: Additonal functions
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
