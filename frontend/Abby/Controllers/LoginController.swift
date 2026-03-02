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
    
    // Check if the user already has a valid token stored
    var hasStoredToken: Bool {
        KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        ) != nil
    }
    
    // MARK: - Email / Password Login
    
    func login(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            let token = try await ApiServices.shared.login(email: email, password: password)
            
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
    
    // MARK: - Create Account
    
    func createAccount(email: String, password: String, vrn: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            try await ApiServices.shared.createAccount(email: email, password: password, vrn: vrn)
            
            // Auto-login after successful registration
            await login(email: email, password: password)
            
        } catch {
            errorMessage = error.localizedDescription
            print("Account creation failed:", error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout() {
        KeychainHelper.shared.delete(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        isLoggedIn = false
    }
    
    // MARK: - OAuth Login
    
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
