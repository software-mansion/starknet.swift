import XCTest

@testable import Starknet

final class TransactionTests: XCTestCase {
    func testInvokeTransactionEncoding() throws {
        let invoke = StarknetSequencerInvokeTransaction(senderAddress: "0x123", calldata: [1, 2], signature: [1, 2], maxFee: "0x859", nonce: 0)
        
        let encoder = JSONEncoder()
        
        let encoded = try encoder.encode(invoke)
        let encodedString = String(data: encoded, encoding: .utf8)!
        
        let pairs = [
            "\"sender_address\":\"0x123\"",
            "\"calldata\":[\"0x1\",\"0x2\"]",
            "\"max_fee\":\"0x859\"",
            "\"signature\":[\"0x1\",\"0x2\"]",
            "\"nonce\":\"0x0\"",
            "\"type\":\"invoke\"",
            "\"version\":\"0x1\""
        ]
        
        pairs.forEach {
            XCTAssertTrue(encodedString.localizedStandardContains($0))
        }
    }
    
    func testInvokeTransactionDecoding() throws {
        let json = """
        {"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"INVOKE","version":"0x1"}
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        
        XCTAssertNoThrow(try decoder.decode(StarknetSequencerInvokeTransaction.self, from: json))
        
        let json2 = """
        {"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"DEPLOY","version":"0x1"}
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try decoder.decode(StarknetSequencerInvokeTransaction.self, from: json2))
        
        let json3 = """
        {"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"INVOKE","version":"0x0"}
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try decoder.decode(StarknetSequencerInvokeTransaction.self, from: json3))
    }
}
