//
//  SettingsView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/4/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Section {
                Form {
                    Text("User settings")
                }
            }
            .navigationTitle(Text("Settings"))
        }
    }
}

#Preview {
    SettingsView()
}
