//
//  MainView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/4/26.
//

import SwiftData
import SwiftUI

struct MainView: View {

    var body: some View {

        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Goals", systemImage: "flag.pattern.checkered") {
                GoalsView()
            }
            Tab("Tools", systemImage: "wrench.and.screwdriver.fill") {
                ToolsView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }

        }
    }
}
#Preview {
    MainView()
        .modelContainer(SampleData.container)
}
