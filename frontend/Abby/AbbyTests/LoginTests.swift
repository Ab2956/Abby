import Testing
import Foundation
@testable import AbbyIOS

@MainActor
struct LoginTests {
    
    /// Create an ApiServices instance backed by a mock session
    private func makeApi(session: URLSession) -> ApiServices {
        return ApiServices(session: session)
    }
    
    /// Build a mock HTTP response for a given URL string
    private func mockResponse(url: String, statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    // Login Success
    
    @Test func loginSuccess_setsIsLoggedInTrue() async throws {
        // Arrange: mock server returns a JWT token
        let fakeToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.signature"
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.path == "/login")
            #expect(request.httpMethod == "POST")
            
            // Verify the request body contains email and password
            let body = try JSONSerialization.jsonObject(with: request.httpBody!) as! [String: String]
            #expect(body["email"] == "test@example.com")
            #expect(body["password"] == "password123")
            
            let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 200)
            // Backend returns token as a JSON string: "token..."
            let data = try JSONSerialization.data(withJSONObject: fakeToken)
            return (response, data)
        }
        
        let api = makeApi(session: session)
        
        // Act
        let token = try await api.login(email: "test@example.com", password: "password123")
        
        // Assert
        #expect(token == fakeToken)
    }
    
    @Test func loginSuccess_controllerSavesTokenAndNavigates() async throws {
        let fakeToken = "jwt-token-abc"
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: fakeToken)
            return (response, data)
        }
        
        // Inject the mock session into the shared ApiServices for this test
        let originalSession = ApiServices.shared.session
        ApiServices.shared.session = session
        defer { ApiServices.shared.session = originalSession }
        
        let controller = LoginController()
        
        // Pre-conditions
        #expect(controller.isLoggedIn == false)
        #expect(controller.errorMessage == nil)
        
        // Act
        await controller.login(email: "test@example.com", password: "password123")
        
        // Assert
        #expect(controller.isLoggedIn == true)
        #expect(controller.errorMessage == nil)
        #expect(controller.isLoading == false)
        
        // Verify token was saved to Keychain
        let savedToken = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        #expect(savedToken == fakeToken)
        
        // Clean up Keychain
        KeychainHelper.shared.delete(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
    }
    
    // Login Failure — Invalid Credentials
    
    @Test func loginFailure_invalidCredentials_setsErrorMessage() async throws {
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 401)
            let data = Data("{\"error\":\"Invalid password\"}".utf8)
            return (response, data)
        }
        
        let originalSession = ApiServices.shared.session
        ApiServices.shared.session = session
        defer { ApiServices.shared.session = originalSession }
        
        let controller = LoginController()
        
        await controller.login(email: "test@example.com", password: "wrong")
        
        #expect(controller.isLoggedIn == false)
        #expect(controller.errorMessage != nil)
        #expect(controller.isLoading == false)
    }
    
    // Login Failure — No User
    
    @Test func loginFailure_noUser_setsErrorMessage() async throws {
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 404)
            let data = Data("{\"error\":\"no user create an account\"}".utf8)
            return (response, data)
        }
        
        let originalSession = ApiServices.shared.session
        ApiServices.shared.session = session
        defer { ApiServices.shared.session = originalSession }
        
        let controller = LoginController()
        
        await controller.login(email: "nobody@example.com", password: "pass")
        
        #expect(controller.isLoggedIn == false)
        #expect(controller.errorMessage != nil)
    }
    
    // Logout
    
    @Test func logout_clearsTokenAndResetsState() async throws {
        let controller = LoginController()
        
        // Simulate a logged-in state
        _ = KeychainHelper.shared.save(
            token: "some-token",
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        controller.isLoggedIn = true
        
        // Act
        controller.logout()
        
        // Assert
        #expect(controller.isLoggedIn == false)
        
        let token = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        #expect(token == nil)
    }
    
    // hasStoredToken
    
    @Test func hasStoredToken_returnsTrueWhenTokenExists() async throws {
        // Clean slate
        KeychainHelper.shared.delete(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        
        let controller = LoginController()
        #expect(controller.hasStoredToken == false)
        
        _ = KeychainHelper.shared.save(
            token: "token",
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        
        #expect(controller.hasStoredToken == true)
        
        // Clean up
        KeychainHelper.shared.delete(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
    }
    
    // Loading State
    
    @Test func login_isLoadingFalseAfterCompletion() async throws {
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: "token")
            return (response, data)
        }
        
        let originalSession = ApiServices.shared.session
        ApiServices.shared.session = session
        defer {
            ApiServices.shared.session = originalSession
            KeychainHelper.shared.delete(
                service: Constants.keychainService,
                account: Constants.keychainAccount
            )
        }
        
        let controller = LoginController()
        
        await controller.login(email: "a@b.com", password: "123456")
        
        #expect(controller.isLoading == false)
    }
}
