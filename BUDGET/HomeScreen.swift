//
//  HomeScreen.swift
//  BUDGET
//
//  Created by Brian Merino on 2/15/26.
//

import SwiftUI
import SwiftData

struct HomeScreen: View {
    @Query private var accounts: [Account]
    @Environment(\.modelContext) private var modelContext
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20){
                    if accounts.isEmpty{
                        //new user
                        emptyStateView
                    }
                    else{
                        //Show user account information
                        //accountBalanceCard
                        //totalSpentCard
                        //transactionHistorySection
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Budget Tracker")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    //createTestData()
                } label: {
                    Label("Add Test Data", systemImage: "plus")
                }
            }
        }
    }
    
    private var emptyStateView: some View{
        VStack(spacing: 20) {
            Image(systemName: "banknote")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("No account yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the + button to add test data")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    HomeScreen()
        .modelContainer(for: [Account.self, Transaction.self])
}
