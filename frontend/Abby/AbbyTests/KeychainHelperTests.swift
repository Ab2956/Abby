import XCTest
@testable import AbbyIOS

final class KeychainHelperTests: XCTestCase {
    
    private let testService = "com.abby.tests.keychain"
    private let testAccount = "testToken"
    
    override func setUp() {
        super.setUp()
        KeychainHelper.shared.delete(service: testService, account: testAccount)
    }
    
    override func tearDown() {
        KeychainHelper.shared.delete(service: testService, account: testAccount)
        super.tearDown()
    }
    
    // MARK: - Save & Retrieve
    
    func testSaveAndRetrieve_roundTrips() {
        let token = "my-secret-token-123"
        let saved = KeychainHelper.shared.save(token: token, service: testService, account: testAccount)
        
        XCTAssertTrue(saved)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        XCTAssertEqual(retrieved, token)
    }
    
    // MARK: - Overwrite Existing Token
    
    func testSave_overwritesExistingToken() {
        _ = KeychainHelper.shared.save(token: "old-token", service: testService, account: testAccount)
        _ = KeychainHelper.shared.save(token: "new-token", service: testService, account: testAccount)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        XCTAssertEqual(retrieved, "new-token")
    }
    
    // MARK: - Delete
    
    func testDelete_removesToken() {
        _ = KeychainHelper.shared.save(token: "to-delete", service: testService, account: testAccount)
        
        XCTAssertNotNil(KeychainHelper.shared.get(service: testService, account: testAccount))
        
        KeychainHelper.shared.delete(service: testService, account: testAccount)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Get Returns Nil When Empty
    
    func testGet_returnsNilWhenNoToken() {
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        XCTAssertNil(retrieved)
    }
    
    // MARK: - Different Services Are Isolated
    
    func testDifferentServices_areIsolated() {
        let serviceA = "com.abby.tests.a"
        let serviceB = "com.abby.tests.b"
        let account = "shared-account"
        
        addTeardownBlock {
            KeychainHelper.shared.delete(service: serviceA, account: account)
            KeychainHelper.shared.delete(service: serviceB, account: account)
        }
        
        _ = KeychainHelper.shared.save(token: "tokenA", service: serviceA, account: account)
        _ = KeychainHelper.shared.save(token: "tokenB", service: serviceB, account: account)
        
        XCTAssertEqual(KeychainHelper.shared.get(service: serviceA, account: account), "tokenA")
        XCTAssertEqual(KeychainHelper.shared.get(service: serviceB, account: account), "tokenB")
    }
    
    // MARK: - Empty String Token
    
    func testSave_emptyString_canBeRetrieved() {
        let saved = KeychainHelper.shared.save(token: "", service: testService, account: testAccount)
        XCTAssertTrue(saved)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        XCTAssertEqual(retrieved, "")
    }
    
    // MARK: - Long Token
    
    func testSave_longToken_roundTrips() {
        let longToken = String(repeating: "a", count: 5000)
        _ = KeychainHelper.shared.save(token: longToken, service: testService, account: testAccount)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        XCTAssertEqual(retrieved, longToken)
    }
    
    // MARK: - Constants Integration
    
    func testConstantsKeychainIdentifiers_areNotEmpty() {
        XCTAssertFalse(Constants.keychainService.isEmpty)
        XCTAssertFalse(Constants.keychainAccount.isEmpty)
    }
}
