//
//  Models.swift
//  BUDGET
//
//  Created by Brian Merino on 2/15/26.
//

import Foundation
import SwiftData

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
    
    var account: Account?
    
    init(amount: Double,
         category: String,
         merchantName: String,
         date: Date = Date(),
         note: String = "",
         isPending: Bool = false){
        self.id = UUID().uuidString
        self.amount = amount
        self.category = category
        self.merchantName = merchantName
        self.date = date
        self.note = note
        self.isPending = isPending
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


