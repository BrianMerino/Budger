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
    @Query private var payPeriods: [PayPeriod]
    @Query private var recurringBills: [RecurringBill]
    @Query private var userSettings: [UserSettings]
    
    @Environment(\.modelContext) private var modelContext
    
    var currentPayPeriod: PayPeriod? {
        payPeriods.first(where: { $0.isCurrent })
    }
    
    var billsDueThisPeriod: [RecurringBill] {
        guard let period = currentPayPeriod else { return[] }
        return recurringBills.filter { bill in
            bill.isActive && bill.isDueIn(startDate: period.startDate, endDate: period.endDate)
        }
    }
    
    var totalBillsAmount: Double {
        billsDueThisPeriod.reduce(0) { $0 + $1.amount }
    }
    
    var discretionaryBudget: Double {
        guard let period = currentPayPeriod else { return 0 }
        return period.income - totalBillsAmount - period.totalSpent
    }
    
    
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if currentPayPeriod == nil {
                            setupNeededView
                        } else {
                            currentPeriodOverview
                            billsSection
                            discretionarySpendingCard
                            currentPeriodTransactions
                        }
                    }
                    .padding()
                }
                .navigationTitle("Budget Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            NavigationLink("Pay Period Settings") {
                                PayPeriodSettingsView()
                            }
                            
                            NavigationLink("Manage Bills") {
                                BillsManagementView()
                            }
                            
                            Button("Add Test Data") {
                                createTestData()
                            }
                            
                            Button("Delete All", role: .destructive) {
                                deleteAllData()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    
    private var setupNeededView: some View {
            VStack(spacing: 20) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("Set Up Your Pay Period")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Tell us when you get paid to start budgeting")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                NavigationLink {
                    PayPeriodSetupView()
                } label: {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    
    private var currentPeriodOverview: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Pay Period")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        if let period = currentPayPeriod {
                            Text("\(period.startDate, style: .date) - \(period.endDate, style: .date)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let period = currentPayPeriod {
                            Text("$\(period.income, specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    
    private var billsSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Bills Due This Period")
                        .font(.headline)
                    
                    Spacer()
                    
                    NavigationLink {
                        BillsManagementView()
                    } label: {
                        Text("Manage")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                if billsDueThisPeriod.isEmpty {
                    Text("No bills due")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    VStack(spacing: 8) {
                        ForEach(billsDueThisPeriod, id: \.id) { bill in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(bill.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Due on day \(bill.dueDay)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("$\(bill.amount, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total Bills")
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$\(totalBillsAmount, specifier: "%.2f")")
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color.red.opacity(0.05))
            .cornerRadius(12)
        }
        
        //discretionary spending
        private var discretionarySpendingCard: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Available for Spending")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("$\(discretionaryBudget, specifier: "%.2f")")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(discretionaryBudget >= 0 ? .blue : .red)
                
                if let period = currentPayPeriod {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text("Income")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("$\(period.income, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Bills")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("$\(totalBillsAmount, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Spent")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("$\(period.totalSpent, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button {
                    // add a transaction
                } label: {
                    Label("Add Transaction", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        
        //show current period transactions
        private var currentPeriodTransactions: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("This Period's Transactions")
                    .font(.headline)
                
                if let period = currentPayPeriod, !period.transactions.isEmpty {
                    ForEach(period.transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                } else {
                    Text("No transactions yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }

    
    private func createTestData() {
            // create current pay period
            let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            let endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
            
            let period = PayPeriod(startDate: startDate, endDate: endDate, income: 2000, isCurrent: true)
            
            // add some bills
            let rent = RecurringBill(name: "Rent", amount: 800, dueDay: 1, category: "Housing")
            let netflix = RecurringBill(name: "Netflix", amount: 15.99, dueDay: 5, category: "Entertainment")
            let carInsurance = RecurringBill(name: "Car Insurance", amount: 120, dueDay: 10, category: "Transportation")
            
            // add some transactions
            let groceries = Transaction(amount: -87.32, category: "Groceries", merchantName: "Whole Foods", date: Date().addingTimeInterval(-86400 * 2))
            let gas = Transaction(amount: -45.00, category: "Transportation", merchantName: "Shell", date: Date().addingTimeInterval(-86400 * 3))
            
            groceries.payPeriod = period
            gas.payPeriod = period
            period.transactions = [groceries, gas]
            
            modelContext.insert(period)
            modelContext.insert(rent)
            modelContext.insert(netflix)
            modelContext.insert(carInsurance)
            
            try? modelContext.save()
        }
    
    private func deleteAllData() {
            for account in accounts {
                modelContext.delete(account)
            }
            for period in payPeriods {
                modelContext.delete(period)
            }
            for bill in recurringBills {
                modelContext.delete(bill)
            }
            for settings in userSettings {
                modelContext.delete(settings)
            }
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
        .modelContainer(for: [Account.self, Transaction.self, PayPeriod.self, RecurringBill.self, UserSettings.self])
}
