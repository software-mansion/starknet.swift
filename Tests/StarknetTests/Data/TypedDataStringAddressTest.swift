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
            
            // Verify that the wallet field is properly decoded as a string
            guard case let .string(walletValue) = typedData.message["wallet"] else {
                XCTFail("Wallet field should be decoded as string, not as felt")
                return
            }
            
            XCTAssertEqual(walletValue, "0x2a7877881132f27cbfff1021f0ca82ffbcadd14e7599f55e03e891c01edc534")
            
            // This should not throw when signing
            let accountAddress = Felt.fromHex("0x1234")!
            let messageHash = try typedData.getMessageHash(accountAddress: accountAddress)
            
            // Verify we get a valid hash (not testing exact value, just that it doesn't crash)
            XCTAssertNotEqual(messageHash, .zero)
        }())
    }
}