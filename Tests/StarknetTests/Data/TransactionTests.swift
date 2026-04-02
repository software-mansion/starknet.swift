@testable import Starknet
import XCTest

let invokeTransactionV3 = """
{
  "sender_address": "0x123",
  "calldata": ["0x1", "0x2"],
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "nonce": "0xD",
  "type": "INVOKE",
  "version": "0x3",
  "transaction_hash": "0x111",
  "resource_bounds": {
    "l1_gas": {
      "max_amount": "0x300",
      "max_price_per_unit": "0x2137"
    },
    "l2_gas": {
      "max_amount": "0x0",
      "max_price_per_unit": "0x0"
    },
    "l1_data_gas": {
      "max_amount": "0x300",
      "max_price_per_unit": "0x2137"
    },
  },
  "tip": "0x0",
  "paymaster_data": [],
  "account_deployment_data": [],
  "nonce_data_availability_mode": "L1",
  "fee_data_availability_mode": "L1",
  "proof_facts": []
}
"""

let invokeTransactionV1 = """
{
  "sender_address": "0x123",
  "calldata": ["0x1", "0x2"],
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "nonce": "0x0",
  "type": "INVOKE",
  "version": "0x1",
  "transaction_hash": "0x111"
}
"""

let invokeTransactionV0 = """
{
  "contract_address": "0x123",
  "calldata": ["0x1", "0x2"],
  "entry_point_selector": "0x123",
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "type": "INVOKE",
  "version": "0x0",
  "transaction_hash": "0x111"
}
"""

let declareTransactinoV0 = """
{
  "class_hash": "0x123",
  "sender_address": "0x123",
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "type": "DECLARE",
  "version": "0x0",
  "transaction_hash": "0x111"
}
"""

let declareTransactionV1 = """
{
  "class_hash": "0x123",
  "sender_address": "0x123",
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "nonce": "0x0",
  "type": "DECLARE",
  "version": "0x1",
  "transaction_hash": "0x111"
}
"""

let declareTransactionV2 = """
{
  "class_hash": "0x123",
  "compiled_class_hash": "0x123",
  "sender_address": "0x123",
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "nonce": "0x0",
  "type": "DECLARE",
  "version": "0x2",
  "transaction_hash": "0x111"
}
"""

let declareTransactionV3 = """
{
  "class_hash": "0x123",
  "compiled_class_hash": "0x123",
  "sender_address": "0x123",
  "max_fee": "0x859",
  "signature": ["0x1", "0x2"],
  "nonce": "0x0",
  "type": "DECLARE",
  "version": "0x3",
  "transaction_hash": "0x111",
  "resource_bounds": {
    "l1_gas": {
      "max_amount": "0x300",
      "max_price_per_unit": "0x2137"
    },
    "l2_gas": {
      "max_amount": "0x0",
      "max_price_per_unit": "0x0"
    },
    "l1_data_gas": {
      "max_amount": "0x300",
      "max_price_per_unit": "0x2137"
    }
  },
  "tip": "0x0",
  "paymaster_data": [],
  "account_deployment_data": [],
  "nonce_data_availability_mode": "L1",
  "fee_data_availability_mode": "L1"
}
"""

let deployTransaction = """
{
  "class_hash": "0x123",
  "constructor_calldata": ["0x1", "0x2"],
  "contract_address_salt": "0x123",
  "type": "DEPLOY",
  "version": "0x0",
  "transaction_hash": "0x111"
}
"""

let deployAccountTransactionV3 = """
{
  "class_hash": "0x123",
  "constructor_calldata": ["0x1", "0x2"],
  "contract_address_salt": "0x123",
  "type": "DEPLOY_ACCOUNT",
  "version": "0x3",
  "max_fee": "0x123",
  "nonce": "0x0",
  "signature": ["0x1", "0x2"],
  "transaction_hash": "0x111",
  "resource_bounds": {
    "l1_gas": {
      "max_amount": "0x300",
      "max_price_per_unit": "0x2137"
    },
    "l2_gas": {
      "max_amount": "0x0",
      "max_price_per_unit": "0x0"
    },
    "l1_data_gas": {
      "max_amount": "0x300",
      "max_price_per_unit": "0x2137"
    },
  },
  "tip": "0x0",
  "paymaster_data": [],
  "nonce_data_availability_mode": "L1",
  "fee_data_availability_mode": "L1"
}
"""

let deployAccountTransactionV1 = """
{
  "class_hash": "0x123",
  "constructor_calldata": ["0x1", "0x2"],
  "contract_address_salt": "0x123",
  "type": "DEPLOY_ACCOUNT",
  "version": "0x1",
  "max_fee": "0x123",
  "nonce": "0x0",
  "signature": ["0x1", "0x2"],
  "transaction_hash": "0x111"
}
"""

let l1HandlerTransaction = """
{
  "contract_address": "0x123",
  "calldata": ["0x1", "0x2"],
  "entry_point_selector": "0x123",
  "nonce": "0x123",
  "type": "L1_HANDLER",
  "version": "0x0",
  "transaction_hash": "0x111"
}
"""

final class TransactionTests: XCTestCase {
    func testInvokeTransactionEncoding() throws {
        let invoke = StarknetInvokeTransactionV1(senderAddress: "0x123", calldata: [1, 2], signature: [1, 2], maxFee: "0x859", nonce: 0)

        let encoder = JSONEncoder()

        let encoded = try encoder.encode(invoke)
        let encodedString = try XCTUnwrap(String(data: encoded, encoding: .utf8))

        let pairs = [
            "\"sender_address\":\"0x123\"",
            "\"calldata\":[\"0x1\",\"0x2\"]",
            "\"max_fee\":\"0x859\"",
            "\"signature\":[\"0x1\",\"0x2\"]",
            "\"nonce\":\"0x0\"",
            "\"type\":\"invoke\"",
            "\"version\":\"0x1\"",
        ]

        for pair in pairs {
            XCTAssertTrue(encodedString.localizedStandardContains(pair))
        }
    }

    func testInvokeV3HashWithProofFacts() throws {
        // Transaction submitted on Sepolia integration network.
        // Expected hash: 0x7C173B8A109AB589694C89431E2C6070EA8662087B012F62081FAB6BACA4F6E
        let tx = try StarknetInvokeTransactionV3(
            senderAddress: XCTUnwrap(Felt(fromHex: "0x7BFCD6BD5B220A1D46921D92924DDEC46BB7E49D05354C76A8714B41269B2F8")),
            calldata: [
                XCTUnwrap(Felt(fromHex: "0x1")),
                XCTUnwrap(Felt(fromHex: "0x70A5DA4F557B77A9C54546E4BCC900806E28793D8E3EAAA207428D2387249B7")),
                XCTUnwrap(Felt(fromHex: "0x31341177714D81AD9CCD0C903211BC056A60E8AF988D0FD918CC43874549653")),
                XCTUnwrap(Felt(fromHex: "0x0")),
            ],
            signature: [],
            resourceBounds: StarknetResourceBoundsMapping(
                l1Gas: StarknetResourceBounds(
                    maxAmount: XCTUnwrap(UInt64AsHex(fromHex: "0x0")),
                    maxPricePerUnit: XCTUnwrap(UInt128AsHex(fromHex: "0x15D3EF79800"))
                ),
                l2Gas: StarknetResourceBounds(
                    maxAmount: XCTUnwrap(UInt64AsHex(fromHex: "0x7757FAC")),
                    maxPricePerUnit: XCTUnwrap(UInt128AsHex(fromHex: "0x2CB417800"))
                ),
                l1DataGas: StarknetResourceBounds(
                    maxAmount: XCTUnwrap(UInt64AsHex(fromHex: "0xC0")),
                    maxPricePerUnit: XCTUnwrap(UInt128AsHex(fromHex: "0x5DC"))
                )
            ),
            nonce: XCTUnwrap(Felt(fromHex: "0x25")),
            proofFacts: [
                XCTUnwrap(Felt(fromHex: "0x50524F4F4630")),
                XCTUnwrap(Felt(fromHex: "0x5649525455414C5F534E4F53")),
                XCTUnwrap(Felt(fromHex: "0x3E98C2D7703B03A7EDB73ED7F075F97F1DCBAA8F717CDF6E1A57BF058265473")),
                XCTUnwrap(Felt(fromHex: "0x5649525455414C5F534E4F5330")),
                XCTUnwrap(Felt(fromHex: "0x2256B2")),
                XCTUnwrap(Felt(fromHex: "0x4272EA7D22D1B1E91D4D6EB1C55FCB5769B676DF746CF2FE77AF8FFFB86EEF2")),
                XCTUnwrap(Felt(fromHex: "0x6989A681C469D769F3A706C56550A63741A4B2D32BEF4B1209A26DAAD1DBB6")),
                XCTUnwrap(Felt(fromHex: "0x0")),
            ]
        )

        let hash = StarknetTransactionHashCalculator.computeHash(of: tx, chainId: .integration_sepolia)

        XCTAssertEqual(hash, Felt(fromHex: "0x7C173B8A109AB589694C89431E2C6070EA8662087B012F62081FAB6BACA4F6E"))
    }

    func testTransactionWrapperDecoding() throws {
        let cases: [(String, StarknetTransactionType, StarknetTransactionVersion)] = [
            (invokeTransactionV3, .invoke, .v3),
            (invokeTransactionV1, .invoke, .v1),
            (invokeTransactionV0, .invoke, .v0),
            (declareTransactinoV0, .declare, .v0),
            (declareTransactionV1, .declare, .v1),
            (declareTransactionV2, .declare, .v2),
            (declareTransactionV3, .declare, .v3),
            (deployTransaction, .deploy, .v0),
            (deployAccountTransactionV1, .deployAccount, .v1),
            (deployAccountTransactionV3, .deployAccount, .v3),
            (l1HandlerTransaction, .l1Handler, .v0),
        ]

        try cases.forEach { (string: String, type: StarknetTransactionType, version: StarknetTransactionVersion) in
            let data = string.data(using: .utf8)!

            let decoder = JSONDecoder()
            let result: TransactionWrapper = try decoder.decode(TransactionWrapper.self, from: data)
            XCTAssertNotNil(result.transaction)
            XCTAssertTrue(result.transaction.type == type && result.transaction.version == version)
        }
    }
}
