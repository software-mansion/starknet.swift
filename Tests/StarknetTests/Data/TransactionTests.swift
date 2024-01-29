import XCTest

@testable import Starknet

let invokeTransactionV3 = """
{"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0xD","type":"INVOKE","version":"0x3","transaction_hash":"0x111","resource_bounds":{"l1_gas":{"max_amount":"0x300","max_price_per_unit":"0x2137"},"l2_gas":{"max_amount":"0x0","max_price_per_unit":"0x0"}},"tip":"0x0","paymaster_data":[],"account_deployment_data":[],"nonce_data_availability_mode":"L1","fee_data_availability_mode":"L1"}
"""

let invokeTransactionV1 = """
{"sender_address":"0x123","calldata":["0x1","0x2"],"max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"INVOKE","version":"0x1","transaction_hash":"0x111"}
"""

let invokeTransactionV0 = """
{"contract_address":"0x123","calldata":["0x1","0x2"],"entry_point_selector":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"type":"INVOKE","version":"0x0","transaction_hash":"0x111"}
"""

let declareTransactinoV0 = """
{"class_hash":"0x123","sender_address":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"type":"DECLARE","version":"0x0","transaction_hash":"0x111"}
"""

let declareTransactionV1 = """
{"class_hash":"0x123","sender_address":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"DECLARE","version":"0x1","transaction_hash":"0x111"}
"""

let declareTransactionV2 = """
{"class_hash":"0x123","compiled_class_hash":"0x123","sender_address":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"DECLARE","version":"0x2","transaction_hash":"0x111"}
"""

let declareTransactionV3 = """
{"class_hash":"0x123","compiled_class_hash":"0x123","sender_address":"0x123","max_fee":"0x859","signature":["0x1","0x2"],"nonce":"0x0","type":"DECLARE","version":"0x3","transaction_hash":"0x111","resource_bounds":{"l1_gas":{"max_amount":"0x300","max_price_per_unit":"0x2137"},"l2_gas":{"max_amount":"0x0","max_price_per_unit":"0x0"}},"tip":"0x0","paymaster_data":[],"account_deployment_data":[],"nonce_data_availability_mode":"L1","fee_data_availability_mode":"L1"}
"""

let deployTransaction = """
{"class_hash":"0x123","constructor_calldata":["0x1","0x2"],"contract_address_salt":"0x123","type":"DEPLOY","version":"0x0","transaction_hash":"0x111"}
"""

let deployAccountTransactionV3 = """
{"class_hash":"0x123","constructor_calldata":["0x1","0x2"],"contract_address_salt":"0x123","type":"DEPLOY_ACCOUNT","version":"0x3","max_fee":"0x123","nonce":"0x0","signature":["0x1","0x2"],"transaction_hash":"0x111", "resource_bounds":{"l1_gas":{"max_amount":"0x300","max_price_per_unit":"0x2137"},"l2_gas":{"max_amount":"0x0","max_price_per_unit":"0x0"}},"tip":"0x0","paymaster_data":[],"nonce_data_availability_mode":"L1","fee_data_availability_mode":"L1"}
"""

let deployAccountTransactionV1 = """
{"class_hash":"0x123","constructor_calldata":["0x1","0x2"],"contract_address_salt":"0x123","type":"DEPLOY_ACCOUNT","version":"0x1","max_fee":"0x123","nonce":"0x0","signature":["0x1","0x2"],"transaction_hash":"0x111"}
"""

let l1HandlerTransaction = """
{"contract_address":"0x123","calldata":["0x1","0x2"],"entry_point_selector":"0x123","nonce":"0x123","type":"L1_HANDLER","version":"0x0","transaction_hash":"0x111"}
"""

final class TransactionTests: XCTestCase {
    func testInvokeTransactionEncoding() throws {
        let invoke = StarknetInvokeTransactionV1(senderAddress: "0x123", calldata: [1, 2], signature: [1, 2], maxFee: "0x859", nonce: 0)

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
        let cases: [(String, StarknetTransactionType, Felt)] = [
            (invokeTransactionV3, .invoke, 3),
            (invokeTransactionV1, .invoke, 1),
            (invokeTransactionV0, .invoke, 0),
            (declareTransactinoV0, .declare, 0),
            (declareTransactionV1, .declare, 1),
            (declareTransactionV2, .declare, 2),
            (declareTransactionV3, .declare, 3),
            (deployTransaction, .deploy, 0),
            (deployAccountTransactionV1, .deployAccount, 1),
            (deployAccountTransactionV3, .deployAccount, 3),
            (l1HandlerTransaction, .l1Handler, 0),
        ]

        try cases.forEach { (string: String, type: StarknetTransactionType, version: Felt) in
            let data = string.data(using: .utf8)!

            let decoder = JSONDecoder()
            let result: TransactionWrapper = try decoder.decode(TransactionWrapper.self, from: data)
            XCTAssertNotNil(result.transaction)
            XCTAssertTrue(result.transaction.type == type && result.transaction.version == version)
        }
    }
}
