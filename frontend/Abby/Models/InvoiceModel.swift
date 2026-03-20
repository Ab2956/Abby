//
//  InvoiceModel.swift
//  Abby
//
//  Created by Adam Brows on 15/02/2026.
//

import Foundation

// Invoice Line Item

struct InvoiceLineItem: Identifiable, Codable {
    var id = UUID()
    var description: String = ""
    var quantity: Double = 1
    var unitPrice: Double = 0
    var vatRate: Double = 20.0

    var total: Double { quantity * unitPrice }
    var vatAmount: Double { total * (vatRate / 100) }

    enum CodingKeys: String, CodingKey {
        case description, quantity, unitPrice, vatRate
    }
}

// Invoice

struct Invoice: Identifiable, Codable {
    var id: String?
    var clientName: String = ""
    var clientEmail: String = ""
    var invoiceDate: Date = Date()
    var dueDate: Date = Date().addingTimeInterval(30 * 24 * 60 * 60)
    var lineItems: [InvoiceLineItem] = []
    var notes: String = ""

    var subtotal: Double { lineItems.reduce(0) { $0 + $1.total } }
    var totalVAT: Double { lineItems.reduce(0) { $0 + $1.vatAmount } }
    var grandTotal: Double { subtotal + totalVAT }

    enum CodingKeys: String, CodingKey {
        case id, clientName, clientEmail, invoiceDate, dueDate, lineItems, notes
    }
}

// Invoice Upload Response

struct InvoiceUploadResponse: Codable {
    let success: Bool?
    let message: String?
}
