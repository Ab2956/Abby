//
//  ObligationsController.swift
//  Abby
//
//  Created on 05/03/2026.
//

import SwiftUI

@MainActor
class ObligationsController: ObservableObject {

    // MARK: - Published state

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var obligations: [ObligationViewModel] = []
    @Published var selectedFilter: ObligationFilter = .all

    var apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    // MARK: - Fetch obligations from HMRC via backend

    func fetchObligations(vrn: String, from: String, to: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let queryItems = [
                URLQueryItem(name: "vrn", value: vrn),
                URLQueryItem(name: "from", value: from),
                URLQueryItem(name: "to", value: to),
            ]

            let response: ObligationsResponse = try await apiService.authenticatedGet(
                path: "/vat",
                queryItems: queryItems
            )

            // Map the HMRC response to view models
            obligations = mapObligations(from: response)

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Filtered list for the view

    var filteredObligations: [ObligationViewModel] {
        switch selectedFilter {
        case .all: return obligations
        case .pending: return obligations.filter { $0.status == .pending }
        case .fulfilled: return obligations.filter { $0.status == .fulfilled }
        case .overdue: return obligations.filter { $0.status == .overdue }
        }
    }

    var pendingCount: Int { obligations.filter { $0.status == .pending }.count }
    var overdueCount: Int { obligations.filter { $0.status == .overdue }.count }
    var fulfilledCount: Int { obligations.filter { $0.status == .fulfilled }.count }

    // MARK: - Mapping

    private func mapObligations(from response: ObligationsResponse) -> [ObligationViewModel] {
        guard let groups = response.obligations else { return [] }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var result: [ObligationViewModel] = []

        for group in groups {
            for obligation in group.obligations {
                let start = dateFormatter.date(from: obligation.start) ?? Date()
                let end = dateFormatter.date(from: obligation.end) ?? Date()
                let due = dateFormatter.date(from: obligation.due) ?? Date()

                let status: ObligationStatus
                switch obligation.status.uppercased() {
                case "F":
                    status = .fulfilled
                case "O":
                    status = due < Date() ? .overdue : .pending
                default:
                    status = .pending
                }

                result.append(ObligationViewModel(
                    periodStart: start,
                    periodEnd: end,
                    dueDate: due,
                    status: status,
                    periodKey: obligation.periodKey
                ))
            }
        }

        return result.sorted { $0.dueDate < $1.dueDate }
    }
}

// MARK: - View Models & Enums

enum ObligationFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case fulfilled = "Fulfilled"
    case overdue = "Overdue"
}

enum ObligationStatus: String {
    case pending = "Pending"
    case fulfilled = "Fulfilled"
    case overdue = "Overdue"

    var color: Color {
        switch self {
        case .pending: return .orange
        case .fulfilled: return .green
        case .overdue: return .red
        }
    }

    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .fulfilled: return "checkmark.circle.fill"
        case .overdue: return "exclamationmark.circle.fill"
        }
    }
}

struct ObligationViewModel: Identifiable {
    let id = UUID()
    let periodStart: Date
    let periodEnd: Date
    let dueDate: Date
    let status: ObligationStatus
    let periodKey: String?

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
}
