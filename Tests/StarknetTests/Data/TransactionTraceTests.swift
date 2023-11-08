import XCTest

@testable import Starknet

final class TransactionTraceTests: XCTestCase {
    func testSimulateTransactionsResponseDecoding() async throws {
        let json = """
        [
            {
                "transaction_trace": {
                    "validate_invocation": {
                        "contract_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                        "entry_point_selector": "0x162da33a4585851fe8d3af3c2a9c60b557814e221e0d4f30ff0b2189d9c7775",
                        "calldata": [
                            "0x1",
                            "0x4ef3fc1d1bcc844119c21708b7233ed2761bf4c72e70234b90b48a7a92e958e",
                            "0x362398bec32bc0ebb411203221a35a0301193a96f317ebe5e40be9f60d15320",
                            "0x0",
                            "0x1",
                            "0x1",
                            "0x3e8"
                        ],
                        "caller_address": "0x0",
                        "class_hash": "0x2adf83bff049ca835150c9b55dffd380671e2ce2044dba23b8859fb783d6d5a",
                        "entry_point_type": "EXTERNAL",
                        "call_type": "CALL",
                        "result": [],
                        "calls": [],
                        "events": [],
                        "messages": []
                    },
                    "execute_invocation": {
                        "contract_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                        "entry_point_selector": "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad",
                        "calldata": [
                            "0x1",
                            "0x4ef3fc1d1bcc844119c21708b7233ed2761bf4c72e70234b90b48a7a92e958e",
                            "0x362398bec32bc0ebb411203221a35a0301193a96f317ebe5e40be9f60d15320",
                            "0x0",
                            "0x1",
                            "0x1",
                            "0x3e8"
                        ],
                        "caller_address": "0x0",
                        "class_hash": "0x2adf83bff049ca835150c9b55dffd380671e2ce2044dba23b8859fb783d6d5a",
                        "entry_point_type": "EXTERNAL",
                        "call_type": "CALL",
                        "result": [],
                        "calls": [
                            {
                                "contract_address": "0x4ef3fc1d1bcc844119c21708b7233ed2761bf4c72e70234b90b48a7a92e958e",
                                "entry_point_selector": "0x362398bec32bc0ebb411203221a35a0301193a96f317ebe5e40be9f60d15320",
                                "calldata": [
                                    "0x3e8"
                                ],
                                "caller_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                "class_hash": "0x189ce59d98d8d3883a5a9fc7026cc94519ca099147196680734ec46aee5e750",
                                "entry_point_type": "EXTERNAL",
                                "call_type": "CALL",
                                "result": [],
                                "calls": [],
                                "events": [],
                                "messages": []
                            }
                        ],
                        "events": [],
                        "messages": []
                    },
                    "fee_transfer_invocation": {
                        "contract_address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                        "entry_point_selector": "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e",
                        "calldata": [
                            "0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8",
                            "0x47ee1c36452",
                            "0x0"
                        ],
                        "caller_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                        "class_hash": "0xd0e183745e9dae3e4e78a8ffedcce0903fc4900beace4e0abf192d4c202da3",
                        "entry_point_type": "EXTERNAL",
                        "call_type": "CALL",
                        "result": [
                            "0x1"
                        ],
                        "calls": [
                            {
                                "contract_address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                                "entry_point_selector": "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e",
                                "calldata": [
                                    "0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8",
                                    "0x47ee1c36452",
                                    "0x0"
                                ],
                                "caller_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                "class_hash": "0x2760f25d5a4fb2bdde5f561fd0b44a3dee78c28903577d37d669939d97036a0",
                                "entry_point_type": "EXTERNAL",
                                "call_type": "LIBRARY_CALL",
                                "result": [
                                    "0x1"
                                ],
                                "calls": [],
                                "events": [
                                    {
                                        "order": 0,
                                        "keys": [
                                            "0x99cd8bde557814842a3121e8ddfd433a539b8c9f14bf31ebf108d12e6196e9"
                                        ],
                                        "data": [
                                            "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                            "0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8",
                                            "0x47ee1c36452",
                                            "0x0"
                                        ]
                                    }
                                ],
                                "messages": []
                            }
                        ],
                        "events": [],
                        "messages": []
                    },
                    "type": "INVOKE",
                    "state_diff": {
                        "storage_diffs": [
                            {
                                "address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                                "storage_entries": [
                                    {
                                        "key": "0x40a9e89951234e8179e4c60f91fa93f04e26deda7dfb2bccac8a58bead5485e",
                                        "value": "0xaf34586d5fc8d2"
                                    },
                                    {
                                        "key": "0x5496768776e3db30053404f18067d81a6e06f5a2b0de326e21298fd9d569a9a",
                                        "value": "0xf51d1f1148fe2ecc1"
                                    }
                                ]
                            },
                            {
                                "address": "0x4ef3fc1d1bcc844119c21708b7233ed2761bf4c72e70234b90b48a7a92e958e",
                                "storage_entries": [
                                    {
                                        "key": "0x206f38f7e4f15e87567361213c28f235cccdaa1d7fd34c9db1dfe9489c6a091",
                                        "value": "0x3fc"
                                    }
                                ]
                            }
                        ],
                        "nonces": [
                            {
                                "contract_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                "nonce": "0x277"
                            }
                        ],
                        "deployed_contracts": [],
                        "deprecated_declared_classes": [],
                        "declared_classes": [],
                        "replaced_classes": []
                    }
                },
                "fee_estimation": {
                    "gas_consumed": "0x134f",
                    "gas_price": "0x3b9aca0e",
                    "overall_fee": "0x47ee1c36452"
                }
            },
            {
                "transaction_trace": {
                    "validate_invocation": {
                        "contract_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                        "entry_point_selector": "0x162da33a4585851fe8d3af3c2a9c60b557814e221e0d4f30ff0b2189d9c7775",
                        "calldata": [
                            "0x1",
                            "0x4ef3fc1d1bcc844119c21708b7233ed2761bf4c72e70234b90b48a7a92e958e",
                            "0x362398bec32bc0ebb411203221a35a0301193a96f317ebe5e40be9f60d15320",
                            "0x0",
                            "0x1",
                            "0x1",
                            "0x3e8"
                        ],
                        "caller_address": "0x0",
                        "class_hash": "0x2adf83bff049ca835150c9b55dffd380671e2ce2044dba23b8859fb783d6d5a",
                        "entry_point_type": "EXTERNAL",
                        "call_type": "CALL",
                        "result": [],
                        "calls": [],
                        "events": [],
                        "messages": []
                    },
                    "execute_invocation": {
                        "revert_reason": "Placeholder revert reason"
                    },
                    "fee_transfer_invocation": {
                        "contract_address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                        "entry_point_selector": "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e",
                        "calldata": [
                            "0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8",
                            "0x47ee1c36452",
                            "0x0"
                        ],
                        "caller_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                        "class_hash": "0xd0e183745e9dae3e4e78a8ffedcce0903fc4900beace4e0abf192d4c202da3",
                        "entry_point_type": "EXTERNAL",
                        "call_type": "CALL",
                        "result": [
                            "0x1"
                        ],
                        "calls": [
                            {
                                "contract_address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                                "entry_point_selector": "0x83afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e",
                                "calldata": [
                                    "0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8",
                                    "0x47ee1c36452",
                                    "0x0"
                                ],
                                "caller_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                "class_hash": "0x2760f25d5a4fb2bdde5f561fd0b44a3dee78c28903577d37d669939d97036a0",
                                "entry_point_type": "EXTERNAL",
                                "call_type": "LIBRARY_CALL",
                                "result": [
                                    "0x1"
                                ],
                                "calls": [],
                                "events": [
                                    {
                                        "order": 0,
                                        "keys": [
                                            "0x99cd8bde557814842a3121e8ddfd433a539b8c9f14bf31ebf108d12e6196e9"
                                        ],
                                        "data": [
                                            "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                            "0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8",
                                            "0x47ee1c36452",
                                            "0x0"
                                        ]
                                    }
                                ],
                                "messages": []
                            }
                        ],
                        "events": [],
                        "messages": []
                    },
                    "type": "INVOKE",
                    "state_diff": {
                        "storage_diffs": [
                            {
                                "address": "0x4ef3fc1d1bcc844119c21708b7233ed2761bf4c72e70234b90b48a7a92e958e",
                                "storage_entries": [
                                    {
                                        "key": "0x206f38f7e4f15e87567361213c28f235cccdaa1d7fd34c9db1dfe9489c6a091",
                                        "value": "0x7e4"
                                    }
                                ]
                            },
                            {
                                "address": "0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
                                "storage_entries": [
                                    {
                                        "key": "0x40a9e89951234e8179e4c60f91fa93f04e26deda7dfb2bccac8a58bead5485e",
                                        "value": "0xaf2fd98b9c6480"
                                    },
                                    {
                                        "key": "0x5496768776e3db30053404f18067d81a6e06f5a2b0de326e21298fd9d569a9a",
                                        "value": "0xf51d1f59371a65113"
                                    }
                                ]
                            }
                        ],
                        "nonces": [
                            {
                                "contract_address": "0x59083382aadec25d7616a7f48942d72d469b0ac581f2e935ec26b68f66bd600",
                                "nonce": "0x278"
                            }
                        ],
                        "deployed_contracts": [],
                        "deprecated_declared_classes": [],
                        "declared_classes": [],
                        "replaced_classes": []
                    }
                },
                "fee_estimation": {
                    "gas_consumed": "0x134f",
                    "gas_price": "0x3b9aca0e",
                    "overall_fee": "0x47ee1c36452"
                }
            }
        ]
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let simResult = try decoder.decode([StarknetSimulatedTransaction].self, from: json)
        let tx1 = simResult[0].transactionTrace
        let tx2 = simResult[1].transactionTrace
        XCTAssertTrue(tx1 is StarknetInvokeTransactionTrace)
        XCTAssertTrue(tx2 is StarknetRevertedInvokeTransactionTrace)

        let invokeTx = tx1 as! StarknetInvokeTransactionTrace
        let revertedInvokeTx = tx2 as! StarknetRevertedInvokeTransactionTrace
        XCTAssertEqual(invokeTx.type, .invoke)
        XCTAssertNotNil(invokeTx.stateDiff)
        XCTAssertNotNil(invokeTx.feeTransferInvocation)
        XCTAssertNotNil(invokeTx.validateInvocation)

        XCTAssertNotNil(revertedInvokeTx.executeInvocation.revertReason)
    }
}
