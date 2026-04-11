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

    /// Recalculated total: quantity * unit_price
    var calculatedTotal: Double { quantity * unit_price }
    /// VAT for this item
    var calculatedVat: Double { calculatedTotal * (vat_rate / 100.0) }

    enum CodingKeys: String, CodingKey {
        case description, quantity, unit_price, vat_rate, total_price
    }
}

// Invoice Model
struct Invoice: Codable, Identifiable {
    var id: String? = nil// MongoDB _id
    var invoice_number: String = ""
    var invoice_date: Date = Date()
    var invoice_date_iso: String = ""
    var supplier = Supplier(supplier_name: "", supplier_address: "", supplier_contact: nil, supplier_vat_number: "")
    var customer = Customer(customer_name: "", customer_address: "")
    var items: [InvoiceItem] = []
    var total_amount: Double = 0.0
    var vat_amount: Double? = nil

    var calculatedTotalAmount: Double { items.reduce(0) { $0 + $1.calculatedTotal } }
    var calculatedVatAmount: Double { items.reduce(0) { $0 + $1.calculatedVat } }

    func withRecalculatedTotals() -> Invoice {
        var copy = self
        copy.items = items.map { item in
            var updated = item
            updated.total_price = item.calculatedTotal
            return updated
        }
        copy.total_amount = calculatedTotalAmount
        copy.vat_amount = calculatedVatAmount
        return copy
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case invoice_number
        case invoice_date_iso = "invoice_date"
        case supplier, customer, items, total_amount, vat_amount
    }
}
struct InvoiceUploadResponse: Codable {
    let success: Bool?
    let message: String?
}
