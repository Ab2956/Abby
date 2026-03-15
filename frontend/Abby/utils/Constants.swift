//
//  Constants.swift
//  Abby
//
//  Created by Adam Brows on 07/12/2025.
//

import Foundation

struct Constants {
    // will need to change to ip for device testing
    static let baseURL = "http://localhost:8080"
    
    // Keychain identifiers
    static let keychainService = "com.abby.auth"
    static let keychainAccount = "userToken"
    
    // OAuth
    static let oauthCallbackScheme = "abby"
}
