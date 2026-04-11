//
//  VatController.swift
//  AbbyIOS
//
//  Created by Adam Brows on 11/04/2026.
//

import SwiftUI

struct VatTotalResponse: Codable {
    let totalVat: Double
}

@MainActor
class VatController: ObservableObject {

    @Published var totalVat: Double = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: ApiServices

    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }

    func submitVatQuarter() {

    }

    func getVatTotal() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: VatTotalResponse = try await apiService.authenticatedGet(path: "/totalVat")
            totalVat = response.totalVat
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
