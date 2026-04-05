import Foundation
import SwiftUI

class BookkeepingServices: ObservableObject{
    static let shared  = BookkeepingServices()
    
    @Published var receipts : [Receipt] = []
    @Published var isLoading = false
    @Published var error : String?
    
    private var baseUrl = Constants.baseURL
    
    // function get all the users receipts
    func getAllUserReceipts(completion: @escaping ([Receipt]?, String?) -> Void) {
        // url path to the backend to call backend logic
        guard let url = URL(string:"\(baseUrl)/getAllUserReceipts") else {
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
        
        URLSession.shared.dataTask(with: request){ data, response, err in DispatchQueue.main.async{
            self.isLoading = false
        }
            if let err = err{
                print("Receipt net error: \(err)")
                DispatchQueue.main.async {
                    completion(nil, "error: no data")
                    return
                }
            }
            guard let data = data else{
                DispatchQueue.main.async{ completion(nil,"no data returned")}
                return
            }
            if let raw = String(data: data, encoding: .utf8 ) {
                print("raw data: \(raw)")
            }
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let recepits = try decoder.decode([Receipt].self, from :data)
                DispatchQueue.main.async{ completion(recepits, nil)}
            }
            catch{
                DispatchQueue.main.async {
                    completion(nil,"Failed to decode:")
                }
            }
        }.resume()
    }
    
}
