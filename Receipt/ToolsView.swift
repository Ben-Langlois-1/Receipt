//
//  ToolsView.swift
//  Receipt
//
//  Created by Benjamin Langlois on 2/11/26.
//

import SwiftUI

struct ToolsView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Interest calculator") {
                        InterestCalculatorView()
                    }
                }
            }
            .navigationTitle("Tools")
            

        }
    }
}

#Preview {
    ToolsView()
}
