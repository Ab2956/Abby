//
//  MTDController.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

@MainActor
class MTDController: ObservableObject {

    // Published state

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var selectedTaxYear: Int = 2025
    @Published var quarters: [MTDQuarterViewModel] = MTDQuarterViewModel.defaultQuarters()

    var apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    // Submit quarterly update

    /// Submit a single quarter's data to the backend, which formats and sends to HMRC
    func submitQuarter(index: Int) async {
        guard index >= 0, index < quarters.count else { return }

        quarters[index].isSubmitting = true
        errorMessage = nil
        successMessage = nil

        let quarter = quarters[index]

        let body: [String: Any] = [
            "quarter": quarter.quarter,
            "taxYear": selectedTaxYear,
            "turnover": quarter.turnover,
            "otherIncome": quarter.otherIncome,
            "totalExpenses": quarter.totalExpenses,
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)

            guard let token = KeychainHelper.shared.get(
                service: Constants.keychainService,
                account: Constants.keychainAccount
            ),
            let url = URL(string: "\(Constants.baseURL)/mtd/submit") else {
                throw ApiError.badURL
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            DeviceInfoService.shared.applyHeaders(to: &request)
            request.httpBody = jsonData

            let (data, response) = try await apiService.session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.badResponse(statusCode: 0)
            }

            if httpResponse.statusCode >= 400 {
                let message = String(data: data, encoding: .utf8) ?? "Submission failed"
                throw ApiError.serverError(message)
            }

            quarters[index].status = .submitted
            successMessage = "Quarter \(quarter.quarter) submitted successfully"

        } catch {
            errorMessage = error.localizedDescription
        }

        quarters[index].isSubmitting = false
    }

    // Load quarter data from backend

    func loadQuarterData() async {
        isLoading = true
        errorMessage = nil

        // Reset to defaults; in future, fetch saved drafts from backend
        quarters = MTDQuarterViewModel.defaultQuarters()

        isLoading = false
    }

    // Computed properties

    var totalIncome: Double {
        quarters.reduce(0) { $0 + $1.turnover + $1.otherIncome }
    }

    var totalExpenses: Double {
        quarters.reduce(0) { $0 + $1.totalExpenses }
    }

    var netProfit: Double {
        totalIncome - totalExpenses
    }
}

// Quarter View Model

struct MTDQuarterViewModel: Identifiable {
    let id = UUID()
    var quarter: Int
    var periodStart: String
    var periodEnd: String
    var deadline: String
    var turnover: Double = 0
    var otherIncome: Double = 0
    var totalExpenses: Double = 0
    var status: QuarterStatus = .notStarted
    var isSubmitting = false

    var totalIncome: Double { turnover + otherIncome }
    var netProfit: Double { totalIncome - totalExpenses }

    enum QuarterStatus: String {
        case notStarted = "Not Started"
        case draft = "Draft"
        case submitted = "Submitted"
        case overdue = "Overdue"

        var color: Color {
            switch self {
            case .notStarted: return .gray
            case .draft: return .orange
            case .submitted: return .green
            case .overdue: return .red
            }
        }

        var icon: String {
            switch self {
            case .notStarted: return "circle"
            case .draft: return "pencil.circle.fill"
            case .submitted: return "checkmark.circle.fill"
            case .overdue: return "exclamationmark.circle.fill"
            }
        }
    }

    static func defaultQuarters() -> [MTDQuarterViewModel] {
        [
            MTDQuarterViewModel(quarter: 1, periodStart: "6 Apr", periodEnd: "5 Jul", deadline: "7 Aug"),
            MTDQuarterViewModel(quarter: 2, periodStart: "6 Jul", periodEnd: "5 Oct", deadline: "7 Nov"),
            MTDQuarterViewModel(quarter: 3, periodStart: "6 Oct", periodEnd: "5 Jan", deadline: "7 Feb"),
            MTDQuarterViewModel(quarter: 4, periodStart: "6 Jan", periodEnd: "5 Apr", deadline: "7 May"),
        ]
    }
}
