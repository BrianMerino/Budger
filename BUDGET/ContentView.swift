//
//  ContentView.swift
//  BUDGET
//
//  Created by Brian Merino on 1/31/26.
//

import SwiftUI

struct ContentView: View {
    @State private var amount = ""
    @State private var category = ""
    @State private var expenses: [Expense] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // Input Form
                VStack(spacing: 15) {
                    TextField("Amount", text: $amount)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    
                    TextField("Category", text: $category)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Add Expense") {
                        //Attempt to convert what the user entered in the amount category to a double
                        if let amountValue = Double(amount) {
                            let expense = Expense(amount: amountValue, category: category)
                            expenses.append(expense)
                            amount = ""
                            category = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // List of Expenses
                List(expenses) { expense in
                    HStack {
                        Text(expense.category)
                        Spacer()
                        Text("$\(expense.amount, specifier: "%.2f")")
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Budget Tracker")
        }
    }
}

// Simple Expense struct
struct Expense: Identifiable {
    let id = UUID()
    let amount: Double
    let category: String
    let date = Date()
    
}

#Preview {
    ContentView()
}
