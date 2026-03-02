//
//  OauthServices.swift
//  Abby
//
//  Created by Adam Brows on 05/12/2025.
//
import  Foundation

class OauthServices{
    
    private let oauthURL = "localhost:8080/loginAuth"
    private let oauthCallback = "localhost:8080/callback"
    
    func getOauthRedirectURL() -> URL?{
        return URL(string: oauthURL);
    }
    
    func getOauthCallback() -> URL?{
        return URL(string: oauthCallback);
    }
}
