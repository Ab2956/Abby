//
//  loginController.swift
//  Abby
//
//  Created by Adam Brows on 05/12/2025.
//
import SafariServices
import UIKit

class LoginController{
    
    let oauth = OauthServices()
    let apiSevrice = ApiServices.shared
    
    
    func loginOauth(from viewController: UIViewController){
        guard let url = oauth.getOauthRedirectURL() else {
            print("Invalid OAuth URL")
                return
        }
               
        let safariView = SFSafariViewController(url: url)
        viewController.present(safariView, animated: true)
    }
    
    func loginOauthCallback(from viewControler: UIViewController){
        
    }
    
    func login(email: String, password: String) async{
        do {
            let token = try await ApiServices.shared.login(email: email, password: password)
                    
            KeychainHelper.shared.save(
                token: token,
                service: "com.yourapp.auth",
                account: "userToken"
            )
                
            print("Login successful")
                
            } catch {
            print("Login failed:", error.localizedDescription)
            }
        
    }
    
}
