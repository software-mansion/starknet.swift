//
//  TypedDataStringAddressTest.swift
//
//
//  Created by GitHub Copilot for issue #251
//

import BigInt
@testable import Starknet
import XCTest

final class TypedDataStringAddressTest: XCTestCase {
    func testStringAddressTypedDataSigning() throws {
        // This test reproduces the exact issue from GitHub issue #251
        // where a string type containing a hex address fails to decode properly
        
        let typedDataJson = """
        {
            "types": {
                "StarknetDomain": [
                    {"name": "name", "type": "shortstring"},
                    {"name": "version", "type": "shortstring"},
                    {"name": "chainId", "type": "shortstring"},
                    {"name": "revision", "type": "shortstring"}
                ],
                "AccountCreation": [
                    {"name": "accountIndex", "type": "felt"},
                    {"name": "wallet", "type": "string"},
                    {"name": "tosAccepted", "type": "bool"}
                ]
            },
            "primaryType": "AccountCreation",
            "message": {
                "tosAccepted": true,
                "accountIndex": 0,
                "wallet": "0x2a7877881132f27cbfff1021f0ca82ffbcadd14e7599f55e03e891c01edc534"
            },
            "domain": {
                "name": "Perpetuals",
                "version": "v0",
                "chainId": "SN_MAIN",
                "revision": "1"
            }
        }
        """
        
        guard let jsonData = typedDataJson.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to data")
            return
        }
        
        // This should not throw a decodingError
        XCTAssertNoThrow(try {
            let typedData = try JSONDecoder().decode(StarknetTypedData.self, from: jsonData)
            
            // This should not throw when signing (the main issue was that this would fail)
            let accountAddress = Felt.fromHex("0x1234")!
            let messageHash = try typedData.getMessageHash(accountAddress: accountAddress)
            
            // Verify we get a valid hash (not testing exact value, just that it doesn't crash)
            XCTAssertNotEqual(messageHash, .zero)
        }())
    }
    
    func testStringTypesWithVariousFormats() throws {
        // Test various string formats to ensure our fix handles edge cases
        let testCases = [
            ("0x123", "Short hex string"),
            ("0x0", "Zero hex string"),
            ("regular string", "Non-hex string"),
            ("", "Empty string"),
            ("0x2a7877881132f27cbfff1021f0ca82ffbcadd14e7599f55e03e891c01edc534", "Long hex string (original case)")
        ]
        
        for (walletValue, description) in testCases {
            let typedDataJson = """
            {
                "types": {
                    "StarknetDomain": [
                        {"name": "name", "type": "shortstring"},
                        {"name": "version", "type": "shortstring"},
                        {"name": "chainId", "type": "shortstring"},
                        {"name": "revision", "type": "shortstring"}
                    ],
                    "Test": [
                        {"name": "value", "type": "string"}
                    ]
                },
                "primaryType": "Test",
                "message": {
                    "value": "\(walletValue)"
                },
                "domain": {
                    "name": "Test",
                    "version": "v1",
                    "chainId": "TEST",
                    "revision": "1"
                }
            }
            """
            
            guard let jsonData = typedDataJson.data(using: .utf8) else {
                XCTFail("Failed to convert JSON string to data for case: \(description)")
                continue
            }
            
            // Each case should successfully decode and produce a message hash
            XCTAssertNoThrow(try {
                let typedData = try JSONDecoder().decode(StarknetTypedData.self, from: jsonData)
                let accountAddress = Felt.fromHex("0x1234")!
                let messageHash = try typedData.getMessageHash(accountAddress: accountAddress)
                XCTAssertNotEqual(messageHash, .zero, "Failed for case: \(description)")
            }(), "Should not throw for case: \(description)")
        }
    }
    
    func testStringTypesRevision0() throws {
        // Test that v0 revision also works (it uses unwrapFelt instead of unwrapLongString)
        let typedDataJson = """
        {
            "types": {
                "StarkNetDomain": [
                    {"name": "name", "type": "felt"},
                    {"name": "version", "type": "felt"},
                    {"name": "chainId", "type": "felt"}
                ],
                "Test": [
                    {"name": "value", "type": "string"}
                ]
            },
            "primaryType": "Test",
            "message": {
                "value": "0x2a7877881132f27cbfff1021f0ca82ffbcadd14e7599f55e03e891c01edc534"
            },
            "domain": {
                "name": "Test",
                "version": "1",
                "chainId": "2137"
            }
        }
        """
        
        guard let jsonData = typedDataJson.data(using: .utf8) else {
            XCTFail("Failed to convert JSON string to data")
            return
        }
        
        // v0 should also work (uses unwrapFelt for strings)
        XCTAssertNoThrow(try {
            let typedData = try JSONDecoder().decode(StarknetTypedData.self, from: jsonData)
            let accountAddress = Felt.fromHex("0x1234")!
            let messageHash = try typedData.getMessageHash(accountAddress: accountAddress)
            XCTAssertNotEqual(messageHash, .zero)
        }())
    }
}