//
//  InvoiceModel.swift
//  Abby
//
//  Created by Adam Brows on 15/02/2026.
//

import Foundation

// Supplier Model
struct Supplier: Codable {
    var supplier_name: String
    var supplier_address: String
    var supplier_contact: String?
    var supplier_vat_number: String
}

// Customer Model
struct Customer: Codable {
    var customer_name: String
    var customer_address: String
}

// Invoice Item Model
struct InvoiceItem: Codable, Identifiable {
    var id = UUID()
    var description: String
    var quantity: Double
    var unit_price: Double
    var vat_rate: Double
    var total_price: Double

    enum CodingKeys: String, CodingKey {
        case description, quantity, unit_price, vat_rate, total_price
    }
}

// Invoice Model
struct Invoice: Codable, Identifiable {
    var id: String? // MongoDB _id
    var invoice_number: String
    var invoice_date: Date
    var supplier: Supplier
    var customer: Customer
    var items: [InvoiceItem]
    var total_amount: Double
    var vat_amount: Double?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case invoice_number, invoice_date, supplier, customer, items, total_amount, vat_amount
    }
}
struct InvoiceUploadResponse: Codable {
    let success: Bool?
    let message: String?
}
