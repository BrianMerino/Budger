//
//  BUDGETApp.swift
//  BUDGET
//
//  Created by Brian Merino on 1/31/26.
//

import SwiftUI
import SwiftData

@main
struct BUDGETApp: App {
    
    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
        .modelContainer(for: [Account.self, Transaction.self, BudgetCategory.self])
    }
}
