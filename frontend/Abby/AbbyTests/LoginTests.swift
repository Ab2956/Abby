import XCTest
@testable import AbbyIOS

@MainActor
final class LoginTests: XCTestCase {
    
    private var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = makeMockSession()
        KeychainHelper.shared.delete(service: Constants.keychainService, account: Constants.keychainAccount)
    }
    
    override func tearDown() {
        mockSession.invalidateAndCancel()
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
    
    // MARK: - Login Success
    
    func testLoginSuccess_setsIsLoggedInTrue() async {
        let fakeToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.signature"
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/login")
            XCTAssertEqual(request.httpMethod, "POST")
            
            let body = try! JSONSerialization.jsonObject(with: request.httpBody!) as! [String: String]
            XCTAssertEqual(body["email"], "test@example.com")
            XCTAssertEqual(body["password"], "password123")
            
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: fakeToken)
            return (response, data)
        }
        
        let controller = makeController()
        await controller.login(email: "test@example.com", password: "password123")
        
        XCTAssertTrue(controller.isLoggedIn)
        XCTAssertNil(controller.errorMessage)
        XCTAssertFalse(controller.isLoading)
    }
    
    func testLoginSuccess_savesTokenToKeychain() async {
        let fakeToken = "jwt-token-abc"
        
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: fakeToken)
            return (response, data)
        }
        
        let controller = makeController()
        await controller.login(email: "test@example.com", password: "password123")
        
        let savedToken = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        XCTAssertEqual(savedToken, fakeToken)
    }
    
    // MARK: - Login Failure
    
    func testLoginFailure_invalidCredentials_setsErrorMessage() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 401)
            let data = Data("{\"error\":\"Invalid password\"}".utf8)
            return (response, data)
        }
        
        let controller = makeController()
        await controller.login(email: "test@example.com", password: "wrong")
        
        XCTAssertFalse(controller.isLoggedIn)
        XCTAssertNotNil(controller.errorMessage)
        XCTAssertFalse(controller.isLoading)
    }
    
    func testLoginFailure_noUser_setsErrorMessage() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 404)
            let data = Data("{\"error\":\"no user create an account\"}".utf8)
            return (response, data)
        }
        
        let controller = makeController()
        await controller.login(email: "nobody@example.com", password: "pass")
        
        XCTAssertFalse(controller.isLoggedIn)
        XCTAssertNotNil(controller.errorMessage)
    }
    
    // MARK: - Logout
    
    func testLogout_clearsTokenAndResetsState() {
        let controller = makeController()
        
        _ = KeychainHelper.shared.save(
            token: "some-token",
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        controller.isLoggedIn = true
        
        controller.logout()
        
        XCTAssertFalse(controller.isLoggedIn)
        let token = KeychainHelper.shared.get(
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        XCTAssertNil(token)
    }
    
    // MARK: - hasStoredToken
    
    func testHasStoredToken_returnsFalseWhenEmpty() {
        let controller = makeController()
        XCTAssertFalse(controller.hasStoredToken)
    }
    
    func testHasStoredToken_returnsTrueWhenTokenExists() {
        _ = KeychainHelper.shared.save(
            token: "token",
            service: Constants.keychainService,
            account: Constants.keychainAccount
        )
        let controller = makeController()
        XCTAssertTrue(controller.hasStoredToken)
    }
    
    // MARK: - Loading State
    
    func testLogin_isLoadingFalseAfterCompletion() async {
        MockURLProtocol.requestHandler = { _ in
            let response = self.mockResponse(path: "/login", statusCode: 200)
            let data = try! JSONSerialization.data(withJSONObject: "token")
            return (response, data)
        }
        
        let controller = makeController()
        await controller.login(email: "a@b.com", password: "123456")
        
        XCTAssertFalse(controller.isLoading)
    }
}
