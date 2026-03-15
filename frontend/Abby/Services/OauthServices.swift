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
    
    func getOauthRedirectURL(token: String? = nil) -> URL? {
        guard var components = URLComponents(string: oauthURL) else { return nil }
        if let token {
            components.queryItems = [URLQueryItem(name: "token", value: token)]
        }
        return components.url
    }
    
    func getOauthCallback() -> URL? {
        return URL(string: oauthCallback)
    }
}
