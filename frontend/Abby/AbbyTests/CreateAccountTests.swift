import XCTest
@testable import AbbyIOS

@MainActor
final class CreateAccountTests: XCTestCase {
    
    private var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = makeMockSession()
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
    
    private func makeController() -> LoginController {
        return LoginController(apiService: ApiServices(session: mockSession))
    }
    
    // MARK: - Successful Account Creation
    
    func testCreateAccount_success_autoLogsIn() async {
        let fakeToken = "new-user-jwt-token"
        var requestCount = 0
        
        MockURLProtocol.requestHandler = { request in
            requestCount += 1
            
            if request.url?.path == "/registerAccount" {
                XCTAssertEqual(request.httpMethod, "POST")
                
                let body = try JSONSerialization.jsonObject(with: request.httpBody!) as! [String: String]
                XCTAssertEqual(body["email"], "new@example.com")
                XCTAssertEqual(body["password"], "securePass1")
                XCTAssertEqual(body["vrn"], "123456789")
                
                let response = self.mockResponse(path: "/registerAccount", statusCode: 200)
                let data = Data("{\"message\":\"Account created successfully\"}".utf8)
                return (response, data)
                
            } else if request.url?.path == "/login" {
                let response = self.mockResponse(path: "/login", statusCode: 200)
                let data = try JSONSerialization.data(withJSONObject: fakeToken)
                return (response, data)
                
            } else {
                throw URLError(.badURL)
            }
        }
        
        let controller = makeController()
        
        await controller.createAccount(
            email: "new@example.com",
            password: "securePass1",
            vrn: "123456789"
        )
        
        XCTAssertEqual(requestCount, 2)
        XCTAssertTrue(controller.isLoggedIn)
        XCTAssertNil(controller.errorMessage)
        XCTAssertFalse(controller.isLoading)
        
        let savedToken = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        XCTAssertEqual(savedToken, fakeToken)
    }
    
    // MARK: - Account Creation Failure
    
    func testCreateAccount_failure_setsErrorMessage() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/registerAccount", statusCode: 500)
            let data = Data("{\"error\":\"Failed to create account\"}".utf8)
            return (response, data)
        }
        
        let controller = makeController()
        
        await controller.createAccount(
            email: "dup@example.com",
            password: "password1",
            vrn: "999999999"
        )
        
        XCTAssertFalse(controller.isLoggedIn)
        XCTAssertNotNil(controller.errorMessage)
        XCTAssertFalse(controller.isLoading)
    }
    
    // MARK: - Register Request Body Validation
    
    func testCreateAccount_sendsCorrectFields() async {
        var capturedBody: [String: String]?
        
        MockURLProtocol.requestHandler = { request in
            if request.url?.path == "/registerAccount" {
                capturedBody = try JSONSerialization.jsonObject(with: request.httpBody!) as? [String: String]
                let response = self.mockResponse(path: "/registerAccount", statusCode: 200)
                return (response, Data("{\"message\":\"ok\"}".utf8))
            }
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try JSONSerialization.data(withJSONObject: "tok")
            return (response, data)
        }
        
        let controller = makeController()
        await controller.createAccount(email: "a@b.com", password: "pass12", vrn: "111222333")
        
        XCTAssertEqual(capturedBody?["email"], "a@b.com")
        XCTAssertEqual(capturedBody?["password"], "pass12")
        XCTAssertEqual(capturedBody?["vrn"], "111222333")
    }
    
    // MARK: - Account Already Exists
    
    func testCreateAccount_duplicateEmail_returnsError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/registerAccount", statusCode: 400)
            let data = Data("email already exists".utf8)
            return (response, data)
        }
        
        let controller = makeController()
        await controller.createAccount(email: "dup@test.com", password: "pass12", vrn: "000")
        
        XCTAssertFalse(controller.isLoggedIn)
        XCTAssertNotNil(controller.errorMessage)
    }
}
