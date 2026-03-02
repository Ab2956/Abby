//
//  KeychainHelperTests.swift
//  AbbyTests
//
//  Tests for the KeychainHelper utility:
//  - Save and retrieve a token
//  - Overwrite an existing token
//  - Delete a token
//  - Retrieve returns nil when no token exists
//

import Testing
import Foundation
@testable import Abby

struct KeychainHelperTests {
    
    // Use unique service/account per test to avoid cross-contamination
    private let testService = "com.abby.tests.keychain"
    private let testAccount = "testToken"
    
    private func cleanup() {
        KeychainHelper.shared.delete(service: testService, account: testAccount)
    }
    
    // MARK: - Save & Retrieve
    
    @Test func saveAndRetrieve_roundTrips() async throws {
        defer { cleanup() }
        cleanup()
        
        let token = "my-secret-token-123"
        let saved = KeychainHelper.shared.save(token: token, service: testService, account: testAccount)
        
        #expect(saved == true)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        #expect(retrieved == token)
    }
    
    // MARK: - Overwrite Existing Token
    
    @Test func save_overwritesExistingToken() async throws {
        defer { cleanup() }
        cleanup()
        
        _ = KeychainHelper.shared.save(token: "old-token", service: testService, account: testAccount)
        _ = KeychainHelper.shared.save(token: "new-token", service: testService, account: testAccount)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        #expect(retrieved == "new-token")
    }
    
    // MARK: - Delete
    
    @Test func delete_removesToken() async throws {
        cleanup()
        
        _ = KeychainHelper.shared.save(token: "to-delete", service: testService, account: testAccount)
        
        // Confirm it exists
        #expect(KeychainHelper.shared.get(service: testService, account: testAccount) != nil)
        
        // Delete
        KeychainHelper.shared.delete(service: testService, account: testAccount)
        
        // Confirm gone
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        #expect(retrieved == nil)
    }
    
    // MARK: - Get Returns Nil When Empty
    
    @Test func get_returnsNilWhenNoToken() async throws {
        cleanup()
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        #expect(retrieved == nil)
    }
    
    // MARK: - Different Services Are Isolated
    
    @Test func differentServices_areIsolated() async throws {
        let serviceA = "com.abby.tests.a"
        let serviceB = "com.abby.tests.b"
        let account = "shared-account"
        
        defer {
            KeychainHelper.shared.delete(service: serviceA, account: account)
            KeychainHelper.shared.delete(service: serviceB, account: account)
        }
        
        _ = KeychainHelper.shared.save(token: "tokenA", service: serviceA, account: account)
        _ = KeychainHelper.shared.save(token: "tokenB", service: serviceB, account: account)
        
        #expect(KeychainHelper.shared.get(service: serviceA, account: account) == "tokenA")
        #expect(KeychainHelper.shared.get(service: serviceB, account: account) == "tokenB")
    }
    
    // MARK: - Empty String Token
    
    @Test func save_emptyString_canBeRetrieved() async throws {
        defer { cleanup() }
        cleanup()
        
        let saved = KeychainHelper.shared.save(token: "", service: testService, account: testAccount)
        #expect(saved == true)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        #expect(retrieved == "")
    }
    
    // MARK: - Long Token
    
    @Test func save_longToken_roundTrips() async throws {
        defer { cleanup() }
        cleanup()
        
        let longToken = String(repeating: "a", count: 5000)
        _ = KeychainHelper.shared.save(token: longToken, service: testService, account: testAccount)
        
        let retrieved = KeychainHelper.shared.get(service: testService, account: testAccount)
        #expect(retrieved == longToken)
    }
    
    // MARK: - Constants Integration
    
    @Test func constantsKeychainIdentifiers_areNotEmpty() async throws {
        #expect(!Constants.keychainService.isEmpty)
        #expect(!Constants.keychainAccount.isEmpty)
    }
}
