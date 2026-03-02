//
//  OauthServices.swift
//  Abby
//
//  Created by Adam Brows on 05/12/2025.
//
import Foundation

class OauthServices {
    
    private var oauthURL: String { "\(Constants.baseURL)/loginAuth" }
    private var oauthCallback: String { "\(Constants.baseURL)/callback" }
    
    func getOauthRedirectURL() -> URL? {
        return URL(string: oauthURL)
    }
    
    func getOauthCallback() -> URL? {
        return URL(string: oauthCallback)
    }
}
