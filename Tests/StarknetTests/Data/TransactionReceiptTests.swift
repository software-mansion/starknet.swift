import XCTest

@testable import Starknet

let invokeReceiptWithBlockInfo = """
{
    "type": "INVOKE",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
    "block_number": 308391,
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789}
}
"""
let invokeReceipt = """
{
    "type": "INVOKE",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789}
}
"""
let declareReceiptWithBlockInfo = """
{
    "type": "DECLARE",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
    "block_number": 308391,
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789}
}
"""
let declareReceipt = """
{
    "type": "DECLARE",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
	"messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789}
}
"""
let deployAccountReceiptWithBlockInfo = """
{
    "type": "DEPLOY_ACCOUNT",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
    "block_number": 308391,
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789},
    "contract_address": "0x789"
}
"""
let deployAccountReceipt = """
{
    "type": "DEPLOY_ACCOUNT",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789},
    "contract_address": "0x789"
}
"""
let deployReceiptWithBlockInfo = """
{
    "type": "DEPLOY",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
    "block_number": 308391,
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789},
    "contract_address": "0x789"
}
"""
let deployReceipt = """
{
    "type": "DEPLOY",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789},
    "contract_address": "0x789"
}
"""
let l1HandlerReceiptWithBlockInfo = """
{
    "type": "L1_HANDLER",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "block_hash": "0x3e1833c6f0bd56a041e150f74e2f5026157d8d3d890ab386eac58c9776da284",
    "block_number": 308391,
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },    
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789},
    "message_hash":"0x2137"
}
"""
let l1HandlerReceipt = """
{
    "type": "L1_HANDLER",
    "transaction_hash": "0x333198614194ae5b5ef921e63898a592de5e9f4d7b6e04745093da88b429f2a",
    "actual_fee": {
                    "amount": "0x244adfc7e22",
                    "unit": "FRI"
                },
    "messages_sent": [],
    "events": [],
    "execution_status": "SUCCEEDED",
    "finality_status": "ACCEPTED_ON_L2",
    "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789},
    "message_hash":"0x2137"
}
"""

final class TransactionReceiptTests: XCTestCase {
    func testTransactionReceiptWrapperDecoding() throws {
        let cases: [(String, StarknetTransactionType, Bool, any StarknetTransactionReceipt.Type)] = [
            (invokeReceiptWithBlockInfo, .invoke, true, StarknetInvokeTransactionReceipt.self),
            (declareReceiptWithBlockInfo, .declare, true, StarknetDeclareTransactionReceipt.self),
            (deployAccountReceiptWithBlockInfo, .deployAccount, true, StarknetDeployAccountTransactionReceipt.self),
            (l1HandlerReceiptWithBlockInfo, .l1Handler, true, StarknetL1HandlerTransactionReceipt.self),
            (deployReceiptWithBlockInfo, .deploy, true, StarknetDeployTransactionReceipt.self),
            (invokeReceipt, .invoke, false, StarknetInvokeTransactionReceipt.self),
            (declareReceipt, .declare, false, StarknetDeclareTransactionReceipt.self),
            (deployAccountReceipt, .deployAccount, false, StarknetDeployAccountTransactionReceipt.self),
            (l1HandlerReceipt, .l1Handler, false, StarknetL1HandlerTransactionReceipt.self),
            (deployReceipt, .deploy, false, StarknetDeployTransactionReceipt.self),
        ]
        try cases.forEach { (string: String, txType: StarknetTransactionType, hasBlockInfo: Bool, receiptType: StarknetTransactionReceipt.Type) in
            let data = string.data(using: .utf8)!
            let decoder = JSONDecoder()

            let receiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: data)
            let receipt = receiptWrapper.transactionReceipt

            if hasBlockInfo {
                XCTAssertNotNil(receipt.blockNumber)
                XCTAssertNotNil(receipt.blockHash)
            } else {
                XCTAssertNil(receipt.blockNumber)
                XCTAssertNil(receipt.blockHash)
            }

            XCTAssertTrue(type(of: receipt) == receiptType)
            XCTAssertEqual(receipt.type, txType)
        }
    }

    func testSuccessfulTransactionReceipt() throws {
        let json = """
        {
            "type": "INVOKE",
            "transaction_hash": "0x157438780a13f8cdfa5c291d666361c112ac0082751fac480e520a7bd78af6d",
            "actual_fee": {
                                "amount": "0x244adfc7e22",
                                "unit": "FRI"
                            },
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
            "finality_status": "ACCEPTED_ON_L1",
            "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789}
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let receiptWrapper: TransactionReceiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: json)
        let receipt = receiptWrapper.transactionReceipt
        XCTAssertNotNil(receipt)
        XCTAssertEqual(receipt.events.count, 2)
        XCTAssertNil(receipt.revertReason)
        XCTAssertTrue(receipt.isSuccessful)
    }

    func testRevertedTransactionReceipt() throws {
        let json = """
        {
            "type": "INVOKE",
            "transaction_hash": "0x5e2e61a59e3f254f2c65109344be985dff979abd01b9c15b659a95f466689bf",
            "actual_fee": {
                            "amount": "0x244adfc7e22",
                            "unit": "FRI"
                        },
            "block_hash": "0x5bc1f6c8303014894a8ba111e6af811b4a1c5a87044312a5ef5f38355b4745a",
            "block_number": 304950,
            "messages_sent": [],
            "events": [],
            "revert_reason": "Error in the called contract (0x03b1b7a7ae9a136a327b01b89ddfee24a474c74bf76032876b5754e44cd7040b):\\nError at pc=0:32:\\nGot an exception while executing a hint: Custom Hint Error: Requested contract address ContractAddress(PatriciaKey(StarkFelt(\\"0x0000000000000000000000000000000000000000000000000000000000000042\\"))) is not deployed.\\nCairo traceback (most recent call last):\\nUnknown location (pc=0:557)\\nUnknown location (pc=0:519)\\nUnknown location (pc=0:625)\\n",
            "execution_status": "REVERTED",
            "finality_status": "ACCEPTED_ON_L1",
            "execution_resources": {"l1_gas": 123, "l1_data_gas": 456, "l2_gas": 789}
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let receiptWrapper: TransactionReceiptWrapper = try decoder.decode(TransactionReceiptWrapper.self, from: json)
        let receipt = receiptWrapper.transactionReceipt

        XCTAssertNotNil(receipt)
        XCTAssertNotNil(receipt.revertReason)
        XCTAssertFalse(receipt.isSuccessful)
    }
}
