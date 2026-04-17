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

    // Recalculated total: quantity * unit_price
    var calculatedTotal: Double { quantity * unit_price }
    // VAT for this item
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
    var invoice_date_iso: Date = Date()
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

    init() {}

    // decode for data similar to the bookkeeping model with parsing and decoded the date format
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        invoice_number = try container.decodeIfPresent(String.self, forKey: .invoice_number) ?? ""
        supplier = try container.decode(Supplier.self, forKey: .supplier)
        customer = try container.decode(Customer.self, forKey: .customer)
        items = try container.decodeIfPresent([InvoiceItem].self, forKey: .items) ?? []
        total_amount = try container.decodeIfPresent(Double.self, forKey: .total_amount) ?? 0
        vat_amount = try container.decodeIfPresent(Double.self, forKey: .vat_amount)

        
        if let dateString = try? container.decode(String.self, forKey: .invoice_date_iso) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsed = formatter.date(from: dateString) {
                invoice_date = parsed
                invoice_date_iso = parsed
            } else {
                let basicFormatter = ISO8601DateFormatter()
                let parsed = basicFormatter.date(from: dateString) ?? Date()
                invoice_date = parsed
                invoice_date_iso = parsed
            }
        } else if let date = try? container.decode(Date.self, forKey: .invoice_date_iso) {
            invoice_date = date
            invoice_date_iso = date
        }
    }
}
struct InvoiceUploadResponse: Codable {
    let success: Bool?
    let message: String?
}
