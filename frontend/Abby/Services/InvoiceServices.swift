import Foundation
import SwiftUI

class InvoiceServices: ObservableObject {
	static let shared = InvoiceServices()

	@Published var invoices: [Invoice] = []
	@Published var isLoading = false
	@Published var error: String?

	private var baseURL: String { Constants.baseURL }

	// function to get the users invoices to be displayed
	func fetchAllUserInvoices(completion: @escaping ([Invoice]?, String?) -> Void) {
		guard let url = URL(string: "\(baseURL)/getAllUserInvoices") else {
			completion(nil, "Invalid URL")
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		if let token = KeychainHelper.shared.get(service: Constants.keychainService, account: Constants.keychainAccount) {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		isLoading = true
		error = nil

		URLSession.shared.dataTask(with: request) { data, response, err in
			DispatchQueue.main.async {
				self.isLoading = false
			}
			// error handling
			if let err = err {
                print("Invoice network err: \(err)")
				DispatchQueue.main.async { completion(nil, err.localizedDescription) }
				return
			}
			guard let data = data else {
                print("no data returned from backend")
				DispatchQueue.main.async { completion(nil, "No data returned") }
				return
			}
            if let raw = String(data: data, encoding: .utf8){
                print("raw json res: \n\(raw)")
            }
			do {
				let invoices = try JSONDecoder().decode([Invoice].self, from: data)
				DispatchQueue.main.async { completion(invoices, nil) }
			} catch {
                print("decoding err: \(error)")
				DispatchQueue.main.async { completion(nil, "Failed to decode invoices: \(error.localizedDescription)") }
			}
		}.resume()
	}
}

