//
//  loginController.swift
//  Abby
//
//  Created by Adam Brows on 05/12/2025.
//
import SafariServices
import UIKit
import SwiftUI

@MainActor
class LoginController: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    let oauth = OauthServices()
    var apiService: ApiServices
    
    init(apiService: ApiServices = .shared) {
        self.apiService = apiService
    }
    
    // checking for valid token when loading
    var hasStoredToken: Bool {
        KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        ) != nil
    }
    
    // login
    
    func login(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            let token = try await apiService.login(email: email, password: password)
            
            _ = KeychainHelper.shared.save(
                token: token,
                service: Constants.keychainService,
                account: Constants.keychainAccount
            )
            
            isLoggedIn = true
            print("Login successful")
            
        } catch {
            errorMessage = error.localizedDescription
            print("Login failed:", error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // create Account
    func createAccount(email: String, password: String, vrn: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            try await apiService.createAccount(email: email, password: password, vrn: vrn)
            await login(email: email, password: password)
            
        } catch {
            errorMessage = error.localizedDescription
            print("Account creation failed:", error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // logout
    
    func logout() {
        KeychainHelper.shared.delete(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        isLoggedIn = false
    }
    
    // OAuth Login
    
    func loginOauth(from viewController: UIViewController) {
        guard let url = oauth.getOauthRedirectURL() else {
            errorMessage = "Invalid OAuth URL"
            print("Invalid OAuth URL")
            return
        }
        
        let safariView = SFSafariViewController(url: url)
        viewController.present(safariView, animated: true)
    }
}
