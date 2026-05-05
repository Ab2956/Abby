//
//  MTDController.swift
//  Abby
//
//  Created by Adam Brows on 05/03/2026.
//

import SwiftUI

// HMRC Obligations Response can be moved tro models

struct HMRCObligationsResponse: Codable {
    let obligations: [HMRCObligation]?
}

struct HMRCObligation: Codable {
    let start: String
    let end: String
    let due: String
    let status: String        
    let periodKey: String?
}

// VAT Return Submission Body

struct VATReturnBody: Codable {
    let periodKey: String
    let vatDueSales: Double
    let vatDueAcquisitions: Double
    let totalVatDue: Double
    let vatReclaimedCurrPeriod: Double
    let netVatDue: Double
    let totalValueSalesExVAT: Double
    let totalValuePurchasesExVAT: Double
    let totalValueGoodsSuppliedExVAT: Double
    let totalAcquisitionsExVAT: Double
    let finalised: Bool
}

// Controller

@MainActor
class MTDController: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var obligations: [VATQuarterViewModel] = []

    var apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    // Fetch obligations from HMRC

    func loadObligations() async {
        isLoading = true
        errorMessage = nil

        do {
            // Compute current UK tax year: April 6 – April 5
            let calendar = Calendar.current
            let now = Date()
            let year = calendar.component(.year, from: now)
            let month = calendar.component(.month, from: now)
            let day = calendar.component(.day, from: now)
            // Tax year starts April 6; if before April 6, start year is previous year
            let taxYearStart = (month < 4 || (month == 4 && day < 6)) ? year - 1 : year
            let from = "\(taxYearStart)-04-06"
            let to = "\(taxYearStart + 1)-04-05"

            let response: HMRCObligationsResponse = try await apiService.authenticatedGet(
                path: "/vat",
                queryItems: [
                    URLQueryItem(name: "from", value: from),
                    URLQueryItem(name: "to", value: to)
                ],
                includeDeviceInfo: true
            )

            if let hmrcObligations = response.obligations {
                obligations = hmrcObligations.enumerated().map { index, ob in
                    VATQuarterViewModel(
                        quarter: index + 1,
                        periodStart: ob.start,
                        periodEnd: ob.end,
                        deadline: ob.due,
                        periodKey: ob.periodKey ?? "",
                        status: ob.status == "F" ? .submitted : .open
                    )
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // Submit a VAT return for a quarter

    func submitVATReturn(index: Int) async {
        guard index >= 0, index < obligations.count else { return }

        obligations[index].isSubmitting = true
        errorMessage = nil
        successMessage = nil

        let quarter = obligations[index]

        let totalVatDue = quarter.vatDueSales + quarter.vatDueAcquisitions
        let netVatDue = abs(totalVatDue - quarter.vatReclaimedCurrPeriod)

        let body = VATReturnBody(
            periodKey: quarter.periodKey,
            vatDueSales: quarter.vatDueSales,
            vatDueAcquisitions: quarter.vatDueAcquisitions,
            totalVatDue: totalVatDue,
            vatReclaimedCurrPeriod: quarter.vatReclaimedCurrPeriod,
            netVatDue: netVatDue,
            totalValueSalesExVAT: quarter.totalValueSalesExVAT,
            totalValuePurchasesExVAT: quarter.totalValuePurchasesExVAT,
            totalValueGoodsSuppliedExVAT: quarter.totalValueGoodsSuppliedExVAT,
            totalAcquisitionsExVAT: quarter.totalAcquisitionsExVAT,
            finalised: true
        )

        do {
            let _: [String: AnyCodable] = try await apiService.authenticatedPost(
                path: "/vat",
                body: body,
                includeDeviceInfo: true
            )
            obligations[index].status = .submitted
            successMessage = "VAT return for period \(quarter.periodKey) submitted successfully"
        } catch {
            errorMessage = error.localizedDescription
        }

        obligations[index].isSubmitting = false
    }

    // summaries

    var totalVatDue: Double {
        obligations.reduce(0) { $0 + $1.vatDueSales + $1.vatDueAcquisitions }
    }

    var totalVatReclaimed: Double {
        obligations.reduce(0) { $0 + $1.vatReclaimedCurrPeriod }
    }

    var netVatDue: Double {
        abs(totalVatDue - totalVatReclaimed)
    }
}

// VAT Quarter View Model can also be moved to models

struct VATQuarterViewModel: Identifiable {
    let id = UUID()
    var quarter: Int
    var periodStart: String
    var periodEnd: String
    var deadline: String
    var periodKey: String

    // VAT return fields
    var vatDueSales: Double = 0
    var vatDueAcquisitions: Double = 0
    var vatReclaimedCurrPeriod: Double = 0
    var totalValueSalesExVAT: Double = 0
    var totalValuePurchasesExVAT: Double = 0
    var totalValueGoodsSuppliedExVAT: Double = 0
    var totalAcquisitionsExVAT: Double = 0

    var status: QuarterStatus = .open
    var isSubmitting = false

    var totalVatDue: Double { vatDueSales + vatDueAcquisitions }
    var netVatDue: Double { abs(totalVatDue - vatReclaimedCurrPeriod) }

    enum QuarterStatus: String {
        case open = "Open"
        case submitted = "Submitted"

        var color: Color {
            switch self {
            case .open: return .orange
            case .submitted: return .green
            }
        }

        var icon: String {
            switch self {
            case .open: return "circle"
            case .submitted: return "checkmark.circle.fill"
            }
        }
    }
}
