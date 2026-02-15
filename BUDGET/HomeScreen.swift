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
                        accountBalanceCard
                        totalSpentCard
                        transactionHistorySection
                    }
                }
                .padding()
            }
            .navigationTitle("Budget Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        createTestData()
                    } label: {
                        Label("Add Test Data", systemImage: "plus")
                    }
                    
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        for account in accounts {
                            modelContext.delete(account)
                        }
                        try? modelContext.save()
                    }
                    label : {
                        Label("Delete All Data", systemImage: "trash")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        print("Accounts in database:")
                            for account in accounts {
                                print("- \(account.name): $\(account.balance)")
                                print("  Transactions: \(account.transactions.count)")
                            }
                    }
                    label : {
                        Label("Print All Data", systemImage: "printer")
                    }
                }
            }
        }
    }
    
    //New user or no activity ever
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
    
    //Top card displaying overall checking account
    private var accountBalanceCard: some View{
        VStack(alignment: .leading, spacing: 12) {
            Text("Checking Account")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if let checkingAccount = accounts.first(where: { $0.type == .checking }) {
                Text("$\(checkingAccount.balance, specifier: "%.2f")")
                    .font(.system(size:42, weight: .bold))
                
                Text("Last updated: \(checkingAccount.lastUpdated, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            else{
                Text("$0.00")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var transactionHistorySection: some View {
        VStack(alignment: .leading, spacing: 12){
            Text("Recent Transactions")
                .font(.headline)
                .padding(.horizontal, 4)
            
            if allTransactions.isEmpty {
                Text("No transactions yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else{
                ForEach(allTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
    
    private var allTransactions: [Transaction] {
        accounts
            .flatMap { $0.transactions }
            .sorted { $0.date > $1.date }
    }
    
    private var totalSpentCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Total Spent This Month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("$\(totalSpent, specifier: "%.2f")")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(12)
    }
    
    
    private var totalSpent: Double {
        let calendar = Calendar.current
        let now = Date()
        
        return allTransactions
            .filter { transaction in
                // Only counting expenses, not income
                transaction.amount < 0 &&
                // Only count this month
                calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
            }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    private func createTestData(){
        let checking = Account(
            name: "Chase Checking",
            type: .checking,
            balance: 2543.67
        )
        
        let groceries = Transaction(amount: -87.32, category: "Groceries", merchantName: "Whole Foods", date: Date().addingTimeInterval(-86400 * 2))

        let gas = Transaction(amount: -45.00, category: "Transportation", merchantName: "Shell Gas Station", date: Date().addingTimeInterval(-86400 * 5))
        
        let restaurant = Transaction(amount: -62.50, category: "Restaurant", merchantName: "Stock & Barrel", date: Date().addingTimeInterval(-86400 * 1))
        
        let paycheck = Transaction(amount: 3000.00, category: "Income", merchantName: "Direct Deposit", date: Date().addingTimeInterval(-86400 * 7))
        
        checking.transactions = [groceries, gas, restaurant, paycheck]
        
        //save to database
        modelContext.insert(checking)
        try? modelContext.save()
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View{
        HStack(spacing: 12) {
            Circle()
                .fill(transaction.amount < 0 ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay{
                    Image(systemName: transaction.amount < 0 ? "arrow.down" : "arrow.up")
                        .foregroundColor(transaction.amount < 0 ? .red : .green)
                        .fontWeight(.semibold)
                }
            
            VStack(alignment: .leading, spacing: 4){
                Text(transaction.merchantName.isEmpty ? transaction.category : transaction.merchantName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 0) {
                    Text(transaction.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("-")
                        .foregroundStyle(.secondary)
                    Text(transaction.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            //Amount
            Text("$\(abs(transaction.amount), specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x : 0, y : 1)
        
    }
}

#Preview {
    HomeScreen()
        .modelContainer(for: [Account.self, Transaction.self])
}
