//
//  Models.swift
//  BUDGET
//
//  Created by Brian Merino on 2/15/26.
//

import Foundation
import SwiftData

@Model
class PayPeriod {
    var id: String
    var startDate: Date
    var endDate: Date
    var income: Double
    var isCurrent: Bool
    
    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction] = []
    
    init(startDate: Date, endDate: Date, income: Double, isCurrent: Bool = false){
        self.id = UUID().uuidString
        self.startDate = startDate
        self.endDate = endDate
        self.income = income
        self.isCurrent = isCurrent
    }
    
    var totalSpent : Double {
        transactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    var remaining: Double {
        income - totalSpent
    }
    
}

@Model
class RecurringBill {
    var id: String
    var name: String
    var amount: Double
    var dueDay: Int
    var category: String
    var isActive: Bool
    var frequency: BillFrequency
    
    init(name: String, amount: Double, dueDay: Int, category: String, frequency: BillFrequency = .monthly, isActive: Bool = true) {
        self.id = UUID().uuidString
        self.name = name
        self.amount = amount
        self.dueDay = dueDay
        self.category = category
        self.frequency = frequency
        self.isActive = isActive
    }
    
    func isDueIn(startDate: Date, endDate: Date) -> Bool {
            let calendar = Calendar.current
            var current = startDate
            
            while current <= endDate {
                let day = calendar.component(.day, from: current)
                if day == dueDay {
                    return true
                }
                current = calendar.date(byAdding: .day, value: 1, to: current)!
            }
            return false
        }
}

enum BillFrequency: String, Codable {
    case weekly
    case biweekly
    case monthly
    case quarterly
    case yearly
}

@Model
class Account{
    var id: String
    var name: String //EX: "Chase checking", "Savings"
    var type: AccountType //EX: checking, saving, credit
    var balance: Double
    var lastUpdated: Date
    
    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction] = []
    
    init(name: String, type: AccountType, balance: Double){
        self.id = UUID().uuidString
        self.name = name
        self.type = type
        self.balance = balance
        self.lastUpdated = Date()
    }
}

enum AccountType: String, Codable {
    case checking
    case savings
    case credit
    case investment
}

@Model
class Transaction{
    var id: String
    var amount: Double //negative for expenses, positive for income
    var date: Date
    var category: String
    var merchantName: String
    var note: String
    var isPending: Bool
    var isRecurringBill: Bool
    var recurringBillId: String?
    
    var account: Account?
    var payPeriod: PayPeriod?
    
    init(amount: Double,
         category: String,
         merchantName: String = "",
         date: Date = Date(),
         note: String = "",
         isPending: Bool = false,
         isRecurringBill: Bool = false) {
        self.id = UUID().uuidString
        self.amount = amount
        self.category = category
        self.merchantName = merchantName
        self.date = date
        self.note = note
        self.isPending = isPending
        self.isRecurringBill = isRecurringBill
        self.recurringBillId = nil
        }
}

@Model
class BudgetCategory {
    var id: String
    var name: String
    var budgetAmount : Double
    var color: String
    var icon: String
    
    init(name: String, budgetAmount: Double, color: String = "#007AFF", icon: String = "dollarsign.circle"){
        self.id = UUID().uuidString
        self.name = name
        self.budgetAmount = budgetAmount
        self.color = color
        self.icon = icon
    }
}

@Model
class UserSettings {
    var id: String
    var payFrequency: PayFrequency
    var nextPayDate : Date
    var typicalPayAmount: Double
    
    init(payFrequency: PayFrequency = .biweekly, nextPayDate: Date = Date(), typicalPayAmount: Double = 0) {
        self.id = UUID().uuidString
        self.payFrequency = payFrequency
        self.nextPayDate = nextPayDate
        self.typicalPayAmount = typicalPayAmount
    }
}

enum PayFrequency: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case biweekly = "Bi-weekly (Every 2 weeks)"
    case semimonthly = "Semi-monthly (Twice a month)"
    case monthly = "Monthly"
    
    var days: Int {
        switch self{
        case .weekly: return 7
        case .biweekly: return 14
        case .semimonthly: return 15
        case .monthly: return 30
        }
    }
}


