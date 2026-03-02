import Testing
import Foundation
@testable import AbbyIOS

struct ApiServicesTests {
    
    // MARK: - Helpers
    
    private func makeApi() -> ApiServices {
        return ApiServices(session: makeMockSession())
    }
    
    private func mockResponse(path: String, statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: Constants.baseURL + path)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    // MARK: - URL Construction
    
    @Test func login_usesCorrectURL() async throws {
        var capturedURL: URL?
        
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: "token")
            return (response, data)
        }
        
        let api = makeApi()
        _ = try await api.login(email: "a@b.com", password: "123")
        
        #expect(capturedURL?.absoluteString == "\(Constants.baseURL)/login")
    }
    
    @Test func createAccount_usesCorrectURL() async throws {
        var capturedURL: URL?
        
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let response = self.mockResponse(path: "/registerAccount", statusCode: 200)
            return (response, Data("{\"message\":\"ok\"}".utf8))
        }
        
        let api = makeApi()
        try await api.createAccount(email: "a@b.com", password: "123", vrn: "456")
        
        #expect(capturedURL?.absoluteString == "\(Constants.baseURL)/registerAccount")
    }
    
    // MARK: - Login Token Parsing
    
    @Test func login_parsesJSONEncodedToken() async throws {
        let expectedToken = "eyJhbGciOiJIUzI1NiJ9.payload.sig"
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            // Backend does res.json(token) which wraps in quotes
            let data = try JSONSerialization.data(withJSONObject: expectedToken)
            return (response, data)
        }
        
        let api = makeApi()
        let token = try await api.login(email: "a@b.com", password: "pass")
        
        #expect(token == expectedToken)
    }
    
    @Test func login_parsesRawStringToken() async throws {
        let expectedToken = "raw-token-no-json-quotes"
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            // Some edge case: token sent as plain text, not JSON
            let data = Data(expectedToken.utf8)
            return (response, data)
        }
        
        let api = makeApi()
        let token = try await api.login(email: "a@b.com", password: "pass")
        
        #expect(token == expectedToken)
    }
    
    // MARK: - Login Error Responses
    
    @Test func login_401_throwsInvalidCredentials() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 401)
            let data = Data("{\"error\":\"Invalid password\"}".utf8)
            return (response, data)
        }
        
        let api = makeApi()
        
        do {
            _ = try await api.login(email: "a@b.com", password: "wrong")
            #expect(Bool(false), "Should have thrown")
        } catch let error as ApiError {
            #expect(error == .invalidCredentials)
        }
    }
    
    @Test func login_404_noUser_throwsNoUser() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 404)
            let data = Data("{\"error\":\"no user create an account\"}".utf8)
            return (response, data)
        }
        
        let api = makeApi()
        
        do {
            _ = try await api.login(email: "nobody@test.com", password: "pass")
            #expect(Bool(false), "Should have thrown")
        } catch let error as ApiError {
            #expect(error == .noUser)
        }
    }
    
    @Test func login_500_throwsServerError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 500)
            let data = Data("{\"error\":\"Internal server error\"}".utf8)
            return (response, data)
        }
        
        let api = makeApi()
        
        do {
            _ = try await api.login(email: "a@b.com", password: "pass")
            #expect(Bool(false), "Should have thrown")
        } catch let error as ApiError {
            if case .serverError = error {
                // correct
            } else {
                #expect(Bool(false), "Expected serverError, got \(error)")
            }
        }
    }
    
    @Test func login_emptyToken_throwsServerError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = Data("\"\"".utf8) // empty JSON string
            return (response, data)
        }
        
        let api = makeApi()
        
        do {
            _ = try await api.login(email: "a@b.com", password: "pass")
            #expect(Bool(false), "Should have thrown")
        } catch let error as ApiError {
            if case .serverError(let msg) = error {
                #expect(msg == "Empty token received")
            } else {
                #expect(Bool(false), "Expected serverError, got \(error)")
            }
        }
    }
    
    // MARK: - Create Account Errors
    
    @Test func createAccount_400_throwsServerError() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/registerAccount", statusCode: 400)
            let data = Data("email already exists".utf8)
            return (response, data)
        }
        
        let api = makeApi()
        
        do {
            try await api.createAccount(email: "dup@test.com", password: "pass", vrn: "123")
            #expect(Bool(false), "Should have thrown")
        } catch let error as ApiError {
            if case .serverError = error {
                // correct
            } else {
                #expect(Bool(false), "Expected serverError, got \(error)")
            }
        }
    }
    
    // MARK: - Authenticated Request Builder
    
    @Test func authenticatedRequest_attachesBearerToken() async throws {
        let testToken = "my-test-jwt"
        
        // Store a token in Keychain
        _ = KeychainHelper.shared.save(
            token: testToken,
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        defer {
            KeychainHelper.shared.delete(
                service: Constants.keychainService,
                account: Constants.keychainAccount
            )
        }
        
        let api = ApiServices()
        let request = api.authenticatedRequest(path: "/profile")
        
        #expect(request != nil)
        #expect(request?.url?.absoluteString == "\(Constants.baseURL)/profile")
        #expect(request?.httpMethod == "GET")
        #expect(request?.value(forHTTPHeaderField: "Authorization") == "Bearer \(testToken)")
        #expect(request?.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }
    
    @Test func authenticatedRequest_returnsNilWithNoToken() async throws {
        // Ensure no token in Keychain
        KeychainHelper.shared.delete(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        
        let api = ApiServices()
        let request = api.authenticatedRequest(path: "/profile")
        
        #expect(request == nil)
    }
    
    @Test func authenticatedRequest_usesSpecifiedMethod() async throws {
        _ = KeychainHelper.shared.save(
            token: "tok",
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        defer {
            KeychainHelper.shared.delete(
                service: Constants.keychainService,
                account: Constants.keychainAccount
            )
        }
        
        let api = ApiServices()
        let request = api.authenticatedRequest(path: "/data", method: "POST")
        
        #expect(request?.httpMethod == "POST")
    }
    
    // MARK: - Request Body Validation
    
    @Test func login_sendsCorrectJSONBody() async throws {
        var capturedBody: [String: String]?
        
        MockURLProtocol.requestHandler = { request in
            capturedBody = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String]
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: "tok")
            return (response, data)
        }
        
        let api = makeApi()
        _ = try await api.login(email: "user@test.com", password: "mypassword")
        
        #expect(capturedBody?["email"] == "user@test.com")
        #expect(capturedBody?["password"] == "mypassword")
    }
    
    @Test func login_setsContentTypeJSON() async throws {
        var capturedContentType: String?
        
        MockURLProtocol.requestHandler = { request in
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: "tok")
            return (response, data)
        }
        
        let api = makeApi()
        _ = try await api.login(email: "a@b.com", password: "p")
        
        #expect(capturedContentType == "application/json")
    }
}

// MARK: - ApiError Equatable conformance for tests
extension ApiError: Equatable {
    public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        switch (lhs, rhs) {
        case (.badURL, .badURL): return true
        case (.noUser, .noUser): return true
        case (.invalidCredentials, .invalidCredentials): return true
        case (.badResponse(let a), .badResponse(let b)): return a == b
        case (.serverError(let a), .serverError(let b)): return a == b
        default: return false
        }
    }
}
