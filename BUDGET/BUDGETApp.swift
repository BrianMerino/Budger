//
//  BUDGETApp.swift
//  BUDGET
//
//  Created by Brian Merino on 1/31/26.
//

import SwiftUI

@main
struct BUDGETApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
