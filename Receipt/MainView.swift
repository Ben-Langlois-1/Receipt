//
//  MainView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/4/26.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeScreen()
            }
            Tab("Goals", systemImage: "flag.pattern.checkered") {
                GoalsView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
    }
}

#Preview {
    MainView()
}
