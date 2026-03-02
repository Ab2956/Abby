import Testing
import Foundation
@testable import AbbyIOS

@MainActor
struct CreateAccountTests {
    
    // MARK: - Helpers
    
    private func mockResponse(url: String, statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    // MARK: - Successful Account Creation
    
    @Test func createAccount_success_autoLogsIn() async throws {
        let fakeToken = "new-user-jwt-token"
        let session = makeMockSession()
        var requestCount = 0
        
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            
            if request.url?.path == "/registerAccount" {
                // First call: create account
                #expect(request.httpMethod == "POST")
                
                let body = try JSONSerialization.jsonObject(with: request.httpBody!) as! [String: String]
                #expect(body["email"] == "new@example.com")
                #expect(body["password"] == "securePass1")
                #expect(body["vrn"] == "123456789")
                
                let response = self.mockResponse(url: Constants.baseURL + "/registerAccount", statusCode: 200)
                let data = Data("{\"message\":\"Account created successfully\"}".utf8)
                return (response, data)
                
            } else if request.url?.path == "/login" {
                // Second call: auto-login after registration
                let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 200)
                let data = try JSONSerialization.data(withJSONObject: fakeToken)
                return (response, data)
                
            } else {
                throw URLError(.badURL)
            }
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
        
        // Act
        await controller.createAccount(
            email: "new@example.com",
            password: "securePass1",
            vrn: "123456789"
        )
        
        // Assert: should have called register + login
        #expect(requestCount == 2)
        #expect(controller.isLoggedIn == true)
        #expect(controller.errorMessage == nil)
        #expect(controller.isLoading == false)
        
        // Token should be in Keychain
        let savedToken = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        #expect(savedToken == fakeToken)
    }
    
    // MARK: - Account Creation Failure
    
    @Test func createAccount_failure_setsErrorMessage() async throws {
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { request in
            let response = self.mockResponse(url: Constants.baseURL + "/registerAccount", statusCode: 500)
            let data = Data("{\"error\":\"Failed to create account\"}".utf8)
            return (response, data)
        }
        
        let originalSession = ApiServices.shared.session
        ApiServices.shared.session = session
        defer { ApiServices.shared.session = originalSession }
        
        let controller = LoginController()
        
        await controller.createAccount(
            email: "dup@example.com",
            password: "password1",
            vrn: "999999999"
        )
        
        #expect(controller.isLoggedIn == false)
        #expect(controller.errorMessage != nil)
        #expect(controller.isLoading == false)
    }
    
    // MARK: - Register Request Body Validation
    
    @Test func createAccount_sendsCorrectFields() async throws {
        let session = makeMockSession()
        var capturedBody: [String: String]?
        
        MockURLProtocol.requestHandler = { request in
            if request.url?.path == "/registerAccount" {
                capturedBody = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String]
                let response = self.mockResponse(url: Constants.baseURL + "/registerAccount", statusCode: 200)
                return (response, Data("{\"message\":\"ok\"}".utf8))
            }
            // Auto-login step
            let response = self.mockResponse(url: Constants.baseURL + "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: "tok")
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
        await controller.createAccount(email: "a@b.com", password: "pass12", vrn: "111222333")
        
        #expect(capturedBody?["email"] == "a@b.com")
        #expect(capturedBody?["password"] == "pass12")
        #expect(capturedBody?["vrn"] == "111222333")
    }
    
    // MARK: - Account Already Exists
    
    @Test func createAccount_duplicateEmail_returnsError() async throws {
        let session = makeMockSession()
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(url: Constants.baseURL + "/registerAccount", statusCode: 400)
            let data = Data("email already exists".utf8)
            return (response, data)
        }
        
        let originalSession = ApiServices.shared.session
        ApiServices.shared.session = session
        defer { ApiServices.shared.session = originalSession }
        
        let controller = LoginController()
        await controller.createAccount(email: "dup@test.com", password: "pass12", vrn: "000")
        
        #expect(controller.isLoggedIn == false)
        #expect(controller.errorMessage != nil)
    }
}
