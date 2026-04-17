//
//  BookkeepingModel.swift
//  Abby
//
//  Created by Adam Brows on 15/02/2026.
//

import Foundation

// Receipt

struct Receipt: Identifiable, Codable {
    var id: String?
    var vendor: String = ""
    var description: String = ""
    var date: Date = Date()
    var totalAmount: Double = 0
    var vatAmount: Double = 0
    var category: String = "Uncategorised"
    var paymentMethod: String = "Cash"
    var isIncome: Bool = false
    var notes: String = ""
    var imageData: Data?

    var netAmount: Double { totalAmount - vatAmount }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case vendor, description, date, totalAmount, vatAmount
        case category, paymentMethod, isIncome, notes
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        vendor = try container.decodeIfPresent(String.self, forKey: .vendor) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        totalAmount = try container.decodeIfPresent(Double.self, forKey: .totalAmount) ?? 0
        vatAmount = try container.decodeIfPresent(Double.self, forKey: .vatAmount) ?? 0
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Uncategorised"
        paymentMethod = try container.decodeIfPresent(String.self, forKey: .paymentMethod) ?? "Cash"
        isIncome = try container.decodeIfPresent(Bool.self, forKey: .isIncome) ?? false
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""

        // Parse date from ISO 8601 string (MongoDB sends dates as ISO strings)
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsed = isoFormatter.date(from: dateString) {
                date = parsed
            } else {
                // Try without fractional seconds
                let basicFormatter = ISO8601DateFormatter()
                date = basicFormatter.date(from: dateString) ?? Date()
            }
        } else if let decodedDate = try? container.decode(Date.self, forKey: .date) {
            date = decodedDate
        }
    }
}

// Receipt Response

struct ReceiptResponse: Codable {
    let message: String?
}

// MTD Quarter

struct MTDQuarter: Identifiable, Codable {
    var id = UUID()
    var quarter: Int
    var taxYear: Int
    var turnover: Double = 0
    var otherIncome: Double = 0
    var expenses: [String: MTDExpense] = [:]
    var status: String = "not_started"

    var totalIncome: Double { turnover + otherIncome }
    var totalExpenses: Double { expenses.values.reduce(0) { $0 + $1.amount } }
    var netProfit: Double { totalIncome - totalExpenses }

    enum CodingKeys: String, CodingKey {
        case quarter, taxYear, turnover, otherIncome, expenses, status
    }
}

struct MTDExpense: Codable {
    var amount: Double = 0
    var disallowableAmount: Double = 0
}

// MTD Submission Response

struct MTDSubmissionResponse: Codable {
    let success: Bool?
    let message: String?
    let period: MTDPeriod?
    let summary: MTDSummary?
}

struct MTDPeriod: Codable {
    let from: String
    let to: String
}

struct MTDSummary: Codable {
    let totalIncome: Double?
    let totalExpenses: Double?
    let netProfit: Double?
}

// Obligation

struct ObligationItem: Identifiable, Codable {
    var id = UUID()
    let start: String
    let end: String
    let due: String
    let status: String
    let periodKey: String?

    enum CodingKeys: String, CodingKey {
        case start, end, due, status, periodKey
    }
}

struct ObligationsResponse: Codable {
    let obligations: [ObligationDetail]?
}

struct ObligationDetail: Codable {
    let start: String
    let end: String
    let due: String
    let status: String
    let periodKey: String?
}


