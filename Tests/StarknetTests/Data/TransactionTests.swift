//
//  File.swift
//  
//
//  Created by Bartosz Rybarski on 08/12/2022.
//

import XCTest

@testable import Starknet

final class TransactionTests: XCTestCase {
    func testInvokeTransactionEncoding() throws {
        let invoke = StarknetSequencerInvokeTransaction(senderAddress: "0x123", calldata: [1, 2], signature: [1, 2, 3, 4, 5], maxFee: 213, nonce: 0)
        
        let encoder = JSONEncoder()
        
        let encoded = try encoder.encode(invoke)
        
        let jsonString = String(data: encoded, encoding: .utf8)!
        
        print(jsonString)
    }
    
    func testInvokeTransactionDecoding() throws {
        let json = """
        {"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"invoke","version":"0x1"}
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        let result = try decoder.decode(StarknetSequencerInvokeTransaction.self, from: json)
        
        print(result)
    }
}
