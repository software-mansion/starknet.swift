import XCTest

@testable import Starknet

let invokeTransaction = """
{"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"INVOKE","version":"0x1","transaction_hash":"0x111"}
"""

let invokeTransactionV0 = """
{"contract_address":"0x123","calldata":["0x1","0x2"],"entry_point_selector":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"INVOKE","version":"0x0","transaction_hash":"0x111"}
"""

let declareTransactionV1 = """
{"class_hash":"0x123","sender_address":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"DECLARE","version":"0x1","transaction_hash":"0x111"}
"""

let deployTransaction = """
{"class_hash":"0x123","constructor_calldata":["0x1","0x2"],"contract_address_salt":"0x123","type":"DEPLOY","version":"0x0","transaction_hash":"0x111"}
"""

let deployAccountTransaction = """
{"class_hash":"0x123","constructor_calldata":["0x1","0x2"],"contract_address_salt":"0x123","type":"DEPLOY_ACCOUNT","version":"0x1","max_fee":"0x123","nonce":"0x0","signature":["0x1","0x2"],"transaction_hash":"0x111"}
"""

let l1HandlerTransaction = """
{"contract_address":"0x123","calldata":["0x1","0x2"],"entry_point_selector":"0x123","nonce":"0x123","type":"L1_HANDLER","version":"0x0","transaction_hash":"0x111"}
"""


final class TransactionTests: XCTestCase {
    func testInvokeTransactionEncoding() throws {
        let invoke = StarknetSequencerInvokeTransaction(senderAddress: "0x123", calldata: [1, 2], signature: [1, 2], maxFee: "0x859", nonce: 0, version: .one)

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
            "\"version\":\"0x1\"",
        ]

        pairs.forEach {
            XCTAssertTrue(encodedString.localizedStandardContains($0))
        }
    }

    func testTransactionWrapperDecoding() throws {
        let cases: [(String, StarknetTransaction.Type)] = [
            (invokeTransaction, StarknetInvokeTransaction.self),
            (invokeTransactionV0, StarknetInvokeTransactionV0.self),
            (declareTransactionV1, StarknetDeclareTransaction.self),
            (deployTransaction, StarknetDeployTransaction.self),
            (deployAccountTransaction, StarknetDeployAccountTransaction.self),
            (l1HandlerTransaction, StarknetL1HandlerTransaction.self)
        ]

        try cases.forEach { (string: String, type: StarknetTransaction.Type) in
            let data = string.data(using: .utf8)!

            let decoder = JSONDecoder()

            XCTAssertNoThrow(try decoder.decode(TransactionWrapper.self, from: data))
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
    }
}
