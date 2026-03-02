import XCTest
@testable import AbbyIOS

final class ApiServicesTests: XCTestCase {
    
    private var api: ApiServices!
    
    override func setUp() {
        super.setUp()
        api = ApiServices(session: makeMockSession())
        KeychainHelper.shared.delete(service: Constants.keychainService, account: Constants.keychainAccount)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        KeychainHelper.shared.delete(service: Constants.keychainService, account: Constants.keychainAccount)
        super.tearDown()
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
    
    func testLogin_usesCorrectURL() async throws {
        var capturedURL: URL?
        
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: "token")
            return (response, data)
        }
        
        _ = try await api.login(email: "a@b.com", password: "123")
        XCTAssertEqual(capturedURL?.absoluteString, "\(Constants.baseURL)/login")
    }
    
    func testCreateAccount_usesCorrectURL() async throws {
        var capturedURL: URL?
        
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let response = self.mockResponse(path: "/registerAccount", statusCode: 200)
            return (response, Data("{\"message\":\"ok\"}".utf8))
        }
        
        try await api.createAccount(email: "a@b.com", password: "123", vrn: "456")
        XCTAssertEqual(capturedURL?.absoluteString, "\(Constants.baseURL)/registerAccount")
    }
    
    // MARK: - Login Token Parsing
    
    func testLogin_parsesJSONEncodedToken() async throws {
        let expectedToken = "eyJhbGciOiJIUzI1NiJ9.payload.sig"
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: expectedToken)
            return (response, data)
        }
        
        let token = try await api.login(email: "a@b.com", password: "pass")
        XCTAssertEqual(token, expectedToken)
    }
    
    func testLogin_parsesRawStringToken() async throws {
        let expectedToken = "raw-token-no-json-quotes"
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = Data(expectedToken.utf8)
            return (response, data)
        }
        
        let token = try await api.login(email: "a@b.com", password: "pass")
        XCTAssertEqual(token, expectedToken)
    }
    
    // MARK: - Login Error Responses
    
    func testLogin_401_throwsInvalidCredentials() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 401)
            let data = Data("{\"error\":\"Invalid password\"}".utf8)
            return (response, data)
        }
        
        do {
            _ = try await api.login(email: "a@b.com", password: "wrong")
            XCTFail("Should have thrown")
        } catch let error as ApiError {
            XCTAssertEqual(error, .invalidCredentials)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testLogin_404_noUser_throwsNoUser() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 404)
            let data = Data("{\"error\":\"no user create an account\"}".utf8)
            return (response, data)
        }
        
        do {
            _ = try await api.login(email: "nobody@test.com", password: "pass")
            XCTFail("Should have thrown")
        } catch let error as ApiError {
            XCTAssertEqual(error, .noUser)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testLogin_500_throwsServerError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 500)
            let data = Data("{\"error\":\"Internal server error\"}".utf8)
            return (response, data)
        }
        
        do {
            _ = try await api.login(email: "a@b.com", password: "pass")
            XCTFail("Should have thrown")
        } catch let error as ApiError {
            if case .serverError = error {
                // correct
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testLogin_emptyToken_throwsServerError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = Data("\"\"".utf8)
            return (response, data)
        }
        
        do {
            _ = try await api.login(email: "a@b.com", password: "pass")
            XCTFail("Should have thrown")
        } catch let error as ApiError {
            if case .serverError(let msg) = error {
                XCTAssertEqual(msg, "Empty token received")
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Create Account Errors
    
    func testCreateAccount_400_throwsServerError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/registerAccount", statusCode: 400)
            let data = Data("email already exists".utf8)
            return (response, data)
        }
        
        do {
            try await api.createAccount(email: "dup@test.com", password: "pass", vrn: "123")
            XCTFail("Should have thrown")
        } catch let error as ApiError {
            if case .serverError = error {
                // correct
            } else {
                XCTFail("Expected serverError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    // MARK: - Authenticated Request Builder
    
    func testAuthenticatedRequest_attachesBearerToken() {
        let testToken = "my-test-jwt"
        _ = KeychainHelper.shared.save(token: testToken, service: Constants.keychainService, account: Constants.keychainAccount)
        
        let request = api.authenticatedRequest(path: "/profile")
        
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.url?.absoluteString, "\(Constants.baseURL)/profile")
        XCTAssertEqual(request?.httpMethod, "GET")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Authorization"), "Bearer \(testToken)")
        XCTAssertEqual(request?.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }
    
    func testAuthenticatedRequest_returnsNilWithNoToken() {
        let request = api.authenticatedRequest(path: "/profile")
        XCTAssertNil(request)
    }
    
    func testAuthenticatedRequest_usesSpecifiedMethod() {
        _ = KeychainHelper.shared.save(token: "tok", service: Constants.keychainService, account: Constants.keychainAccount)
        let request = api.authenticatedRequest(path: "/data", method: "POST")
        XCTAssertEqual(request?.httpMethod, "POST")
    }
    
    // MARK: - Request Body Validation
    
    func testLogin_sendsCorrectJSONBody() async throws {
        var capturedBody: [String: String]?
        
        MockURLProtocol.requestHandler = { request in
            capturedBody = try? JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String]
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: "tok")
            return (response, data)
        }
        
        _ = try await api.login(email: "user@test.com", password: "mypassword")
        XCTAssertEqual(capturedBody?["email"], "user@test.com")
        XCTAssertEqual(capturedBody?["password"], "mypassword")
    }
    
    func testLogin_setsContentTypeJSON() async throws {
        var capturedContentType: String?
        
        MockURLProtocol.requestHandler = { request in
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: "tok")
            return (response, data)
        }
        
        _ = try await api.login(email: "a@b.com", password: "p")
        XCTAssertEqual(capturedContentType, "application/json")
    }
}

// MARK: - ApiError Equatable conformance for tests
extension ApiError: @retroactive Equatable {
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
