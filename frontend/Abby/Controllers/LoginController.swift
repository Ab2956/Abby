//
//  loginController.swift
//  Abby
//
//  Created by Adam Brows on 05/12/2025.
//
import AuthenticationServices
import UIKit
import SwiftUI

@MainActor
class LoginController: ObservableObject {
    
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isLinkedToHMRC = false
    
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
    
    // if the user has a token but no connected to hmrc checks
    func restoreSession() async -> Bool {
        guard hasStoredToken else { return false }

        do {
            let profile = try await apiService.fetchProfile()
            isLinkedToHMRC = profile.isConnectedToHmrc
            isLoggedIn = true
            return true
        } catch {
            // Token is expired or invalid — clear it
            KeychainHelper.shared.delete(
                service: Constants.keychainService,
                account: Constants.keychainAccount
            )
            return false
        }
    }

    // login
    
    func login(email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        
        do {
            let res = try await apiService.login(email: email, password: password)
            let token = res.token
            
            _ = KeychainHelper.shared.save(
                token: token,
                service: Constants.keychainService,
                account: Constants.keychainAccount
            )
            isLinkedToHMRC = res.isConnectedToHmrc
            
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
    
    // for ouath
    func startOAuthSession(presentationAnchor: ASPresentationAnchor) {
        let storedToken = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        guard let url = oauth.getOauthRedirectURL(token: storedToken) else {
            errorMessage = "Invalid OAuth URL"
            return
        }

        let session = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: Constants.oauthCallbackScheme
        ) { [weak self] callbackURL, error in
            Task { @MainActor in
                guard let self else { return }

                if let error {
                    // User cancelled or something went wrong
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        self.errorMessage = nil // user cancelled, no error
                    } else {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }

                guard let callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let success = components.queryItems?.first(where: { $0.name == "success" })?.value else {
                    self.errorMessage = "Invalid callback from HMRC"
                    return
                }

                if success == "true" {
                    self.isLinkedToHMRC = true
                    print("HMRC OAuth linked successfully")
                } else {
                    let msg = components.queryItems?.first(where: { $0.name == "error" })?.value
                    self.errorMessage = msg ?? "Failed to link HMRC"
                    print("HMRC OAuth failed:", self.errorMessage ?? "")
                }
            }
        }

        // Provide the presentation anchor so the auth sheet knows where to appear
        let contextProvider = OAuthPresentationContext(anchor: session, window: presentationAnchor)
        session.presentationContextProvider = contextProvider
        session.prefersEphemeralWebBrowserSession = false
        session.start()
    }
}

// presentation context for ASWebAuthenticationSession

private class OAuthPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let window: ASPresentationAnchor

    init(anchor: ASWebAuthenticationSession, window: ASPresentationAnchor) {
        self.window = window
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window
    }
}
