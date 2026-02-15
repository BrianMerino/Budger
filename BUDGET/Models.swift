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
    var name: String
    var type: AccountType
    var balance: Double
    var lastUpdated: Date
    
    @Relationship(deleteRule: .cascade)
    //var transactions: [Transaction] = []
    
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
