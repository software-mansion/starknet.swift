import XCTest

@testable import Starknet

final class TransactionReceiptTests: XCTestCase {
    func testSuccessfulTransactionReceipt() throws {
        let json = """
        {
            "type": "INVOKE",
            "transaction_hash": "0x157438780a13f8cdfa5c291d666361c112ac0082751fac480e520a7bd78af6d",
            "actual_fee": "0x39f4339b931a",
            "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
            "block_number": 308391,
            "messages_sent": [
                {
                    "from_address": "0x42a0543842846269c710384612ac69418e2ad30b316fe4243717d2ec60494e4",
                    "to_address": "0x1",
                    "payload": [
                        "0xc",
                        "0x22"
                    ]
                },
                {
                    "from_address": "0x42a0543842846269c710384612ac69418e2ad30b316fe4243717d2ec60494e4",
                    "to_address": "0x2",
                    "payload": [
                        "0xc",
                        "0x22"
                    ]
                }
            ],
            "events": [
                {
                    "from_address": "0x5ee5dbac8c39fe9ef8d7761cc84086949d7dc42dd6233cb6310208272ee87ea",
                    "keys": [
                        "0x2db340e6c609371026731f47050d3976552c89b4fbb012941663841c59d1af3"
                    ],
                    "data": [
                        "0x7c930a86c2ed72bea4767b688367e06fd2b2a58915bdd3cfa16fb61b485e8c5"
                    ]
                },
                {
                    "from_address": "0x5ee5dbac8c39fe9ef8d7761cc84086949d7dc42dd6233cb6310208272ee87ea",
                    "keys": [
                        "0x120650e571756796b93f65826a80b3511d4f3a06808e82cb37407903b09d995"
                    ],
                    "data": [
                        "0x0",
                        "0x54d01e5fc6eb4e919ceaab6ab6af192e89d1beb4f29d916768c61a4d48e6c95"
                    ]
                }
            ],
            "execution_status": "SUCCEEDED",
            "finality_status": "ACCEPTED_ON_L1"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        var receiptWrapper: TransactionReceiptWrapper?
        XCTAssertNoThrow(receiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: json))

        let receipt = receiptWrapper?.transactionReceipt

        XCTAssertNotNil(receipt)
        XCTAssertEqual(receipt!.events.count, 2)
        XCTAssertNil(receipt!.revertReason)
        XCTAssertTrue(receipt!.isSuccessful)
    }

    func testRevertedTransactionReceipt() throws {
        let json = """
        {
           "type": "INVOKE",
           "transaction_hash": "0x5e2e61a59e3f254f2c65109344be985dff979abd01b9c15b659a95f466689bf",
           "actual_fee": "0x48cca53dbe80",
           "block_hash": "0x5bc1f6c8303014894a8ba111e6af811b4a1c5a87044312a5ef5f38355b4745a",
           "block_number": 304950,
           "messages_sent": [],
           "events": [],
           "revert_reason": "Error in the called contract (0x03b1b7a7ae9a136a327b01b89ddfee24a474c74bf76032876b5754e44cd7040b):\\nError at pc=0:32:\\nGot an exception while executing a hint: Custom Hint Error: Requested contract address ContractAddress(PatriciaKey(StarkFelt(\\"0x0000000000000000000000000000000000000000000000000000000000000042\\"))) is not deployed.\\nCairo traceback (most recent call last):\\nUnknown location (pc=0:557)\\nUnknown location (pc=0:519)\\nUnknown location (pc=0:625)\\n",
           "execution_status": "REVERTED",
           "finality_status": "ACCEPTED_ON_L1"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        var receiptWrapper: TransactionReceiptWrapper?
        XCTAssertNoThrow(receiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: json))

        let receipt = receiptWrapper?.transactionReceipt

        XCTAssertNotNil(receipt)
        XCTAssertNotNil(receipt!.revertReason)
        XCTAssertFalse(receipt!.isSuccessful)
    }

    func testTransactionReceiptWrapper() throws {
        let pendingReceiptJson = """
        {
            "type": "INVOKE",
            "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
            "actual_fee": "0x244adfc7e22",
            "messages_sent": [],
            "events": [],
            "execution_status": "SUCCEEDED",
            "finality_status": "ACCEPTED_ON_L2"
        }
        """.data(using: .utf8)!
        let commonReceiptJson = """
        {
            "type": "INVOKE",
            "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
            "actual_fee": "0x244adfc7e22",
            "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
            "block_number": 308391,
            "messages_sent": [],
            "events": [],
            "execution_status": "SUCCEEDED",
            "finality_status": "ACCEPTED_ON_L2"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        var pendingReceiptWrapper: TransactionReceiptWrapper?
        XCTAssertNoThrow(pendingReceiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: pendingReceiptJson))
        let pendingReceipt = pendingReceiptWrapper?.transactionReceipt

        XCTAssertTrue(pendingReceipt is StarknetPendingTransactionReceipt)
        XCTAssertFalse(pendingReceipt is StarknetCommonTransactionReceipt)

        var commonReceiptWrapper: TransactionReceiptWrapper?
        XCTAssertNoThrow(commonReceiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: commonReceiptJson))
        let commonReceipt = commonReceiptWrapper?.transactionReceipt

        XCTAssertTrue(commonReceipt is StarknetCommonTransactionReceipt)
        XCTAssertFalse(commonReceipt is StarknetPendingTransactionReceipt)
    }
}
