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
    @State private var showWelcomeView = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Hello, Homescreen!")
                    .font(.title.bold())
            }
            .navigationTitle("Home")
            .onAppear {
                // Show the welcome sheet only if there are no goals yet
                showWelcomeView = allGoals.isEmpty
            }
            .sheet(isPresented: $showWelcomeView) {
                WelcomeView(showWelcomeScreen: $showWelcomeView)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
