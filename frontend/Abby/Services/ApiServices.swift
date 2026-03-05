//
//  ApiServices.swift
//  Abby
//
//  Created by Adam Brows on 12/12/2025.
//
import Foundation

enum ApiError: LocalizedError {
    case badURL
    case badResponse(statusCode: Int)
    case noUser
    case invalidCredentials
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .badURL: return "Invalid URL"
        case .badResponse(let code): return "Bad server response (\(code))"
        case .noUser: return "No account found. Please create an account."
        case .invalidCredentials: return "Invalid email or password."
        case .serverError(let msg): return msg
        }
    }
}

class ApiServices {
    
    static let shared = ApiServices()
    
    /// URLSession used for all requests. Override in tests with a mock session.
    var session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private var baseURL: String { Constants.baseURL }
    
    /// Retrieve the stored JWT token from Keychain
    private var authToken: String? {
        KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
    }
    
    
    /// Returns the JWT token string on success
    func login(email: String, password: String) async throws -> String {
        
        guard let url = URL(string: "\(baseURL)/login") else {
            throw ApiError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.badResponse(statusCode: 0)
        }
        
        // Handle error status codes
        if httpResponse.statusCode == 401 {
            throw ApiError.invalidCredentials
        }
        
        if httpResponse.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            if message.contains("no user") {
                throw ApiError.noUser
            }
            throw ApiError.serverError(message)
        }
        
        let token: String
        if let parsed = try? JSONSerialization.jsonObject(with: data) as? String {
            token = parsed
        } else {
            token = String(decoding: data, as: UTF8.self)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
        
        guard !token.isEmpty else {
            throw ApiError.serverError("Empty token received")
        }
        
        return token
    }
    
    // create Account
    
    func createAccount(email: String, password: String, vrn: String) async throws {
        
        guard let url = URL(string: "\(baseURL)/registerAccount") else {
            throw ApiError.badURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password,
            "vrn": vrn
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.badResponse(statusCode: 0)
        }
        
        if httpResponse.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Account creation failed"
            throw ApiError.serverError(message)
        }
    }
    
    // authenticated Request Helper
    
    /// Build a URLRequest with the JWT Authorization header attached
    func authenticatedRequest(path: String, method: String = "GET") -> URLRequest? {
        guard let url = URL(string: "\(baseURL)\(path)"),
              let token = authToken else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    // MARK: - Authenticated GET / POST helpers

    /// Perform an authenticated GET request and decode the JSON response
    func authenticatedGet<T: Decodable>(path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        guard let token = authToken,
              var components = URLComponents(string: "\(baseURL)\(path)") else {
            throw ApiError.badURL
        }

        components.queryItems = queryItems

        guard let url = components.url else { throw ApiError.badURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Perform an authenticated POST request with a JSON body and decode the response
    func authenticatedPost<T: Decodable>(path: String, body: Encodable) async throws -> T {
        guard let token = authToken,
              let url = URL(string: "\(baseURL)\(path)") else {
            throw ApiError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Perform an authenticated multipart file upload and decode the response
    func authenticatedUpload<T: Decodable>(path: String, fileData: Data, fileName: String, mimeType: String) async throws -> T {
        guard let token = authToken,
              let url = URL(string: "\(baseURL)\(path)") else {
            throw ApiError.badURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }

    /// Perform an authenticated DELETE request
    func authenticatedDelete(path: String) async throws {
        guard let token = authToken,
              let url = URL(string: "\(baseURL)\(path)") else {
            throw ApiError.badURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    // Response validation

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.badResponse(statusCode: 0)
        }

        if httpResponse.statusCode == 401 {
            throw ApiError.invalidCredentials
        }

        if httpResponse.statusCode >= 400 {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ApiError.serverError(message)
        }
    }
}
