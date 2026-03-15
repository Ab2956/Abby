//
//  LoginResponse.swift
//  AbbyIOS
//
//  Created by Adam Brows on 15/03/2026.
//

struct LoginResponse: Decodable{
    let token: String
    let isConnectedToHmrc: Bool
}

