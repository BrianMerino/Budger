//
//  HomeScreen.swift
//  BUDGET
//
//  Created by Brian Merino on 2/15/26.
//

import SwiftUI

struct HomeScreen: View {
    let firstName : String
    var body: some View {
        Text("Welcome, \(firstName)")
    }
}

#Preview {
    HomeScreen(firstName: "Brian")
}
