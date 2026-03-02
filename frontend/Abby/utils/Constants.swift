//
//  Constants.swift
//  Abby
//
//  Created by Adam Brows on 07/12/2025.
//

import Foundation

struct Constants {
    // Change this to your machine's local IP when testing on a physical device
    // e.g. "http://192.168.1.42:8080"
    // Use "http://localhost:8080" for Simulator only
    static let baseURL = "http://localhost:8080"
    
    // Keychain identifiers
    static let keychainService = "com.abby.auth"
    static let keychainAccount = "userToken"
}
