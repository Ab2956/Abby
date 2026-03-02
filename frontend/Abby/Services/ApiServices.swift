//
//  ApiServices.swift
//  Abby
//
//  Created by Adam Brows on 12/12/2025.
//
import Foundation

class ApiServices{
        
        static let shared = ApiServices()
        public init() {}
        
        let baseURL = "localhost:8080/login"
        
        // Login
        func login(email: String, password: String) async throws -> String {
            
            guard let url = URL(string: "\(baseURL)/login") else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = [
                "email": email,
                "password": password
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            
            if let message = String(data: data, encoding: .utf8),
               message.contains("no user") {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: message])
            }
            
            let token = String(decoding: data, as: UTF8.self)
            return token
        }
    }

