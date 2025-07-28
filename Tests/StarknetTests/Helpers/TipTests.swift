import XCTest

@testable import Starknet

final class TipTests: XCTestCase {
    var provider: StarknetProviderProtocol!

    func testEstimateTipForBlockWithoutTxs() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": {
                "block_hash": "0x1",
                "block_number": 111,
                "l1_da_mode": "BLOB",
                "l1_data_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l1_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l2_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "new_root": "0x1",
                "parent_hash": "0x1",
                "sequencer_address": "0x1",
                "starknet_version": "0.14.0",
                "status": "ACCEPTED_ON_L2",
                "timestamp": 123,
                "transactions": []
            }
        }
        """.data(using: .utf8)!

        let session = makeMockedURLSession(data: json)
        let provider = StarknetProvider(url: "https://node.url", urlSession: session)

        let tip = try await estimateTip(provider: provider!)
        XCTAssertEqual(tip, UInt64AsHex.zero)
    }

    func testEstimateTipForBlockWithOddTxsNumber() async throws {
        // 3 transactions, tips: 100, 200, 300
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": {
                "block_hash": "0x1",
                "block_number": 111,
                "l1_da_mode": "BLOB",
                "l1_data_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l1_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l2_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "new_root": "0x1",
                "parent_hash": "0x1",
                "sequencer_address": "0x1",
                "starknet_version": "0.14.0",
                "status": "ACCEPTED_ON_L2",
                "timestamp": 123,
                "transactions": [
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x64",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0xc8",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x12c",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    }
                ]
            }
        }
        """.data(using: .utf8)!

        let session = makeMockedURLSession(data: json)
        let provider = StarknetProvider(url: "https://node.url", urlSession: session)

        let tip = try await estimateTip(provider: provider!)
        XCTAssertEqual(tip, UInt64AsHex(200))
    }

    func testEstimateTipForBlockWithEvenTxsNumber() async throws {
        // 4 transactions, tips: 100, 200, 300, 400
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": {
                "block_hash": "0x1",
                "block_number": 111,
                "l1_da_mode": "BLOB",
                "l1_data_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l1_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l2_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "new_root": "0x1",
                "parent_hash": "0x1",
                "sequencer_address": "0x1",
                "starknet_version": "0.14.0",
                "status": "ACCEPTED_ON_L2",
                "timestamp": 123,
                "transactions": [
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x64",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0xc8",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x12c",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x190",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    }
                ]
            }
        }
        """.data(using: .utf8)!

        let session = makeMockedURLSession(data: json)
        let provider = StarknetProvider(url: "https://node.url", urlSession: session)

        let tip = try await estimateTip(provider: provider!)
        XCTAssertEqual(tip, UInt64AsHex(250))
    }

    func testEstimateTipForBlockWithOldTxs() async throws {
        // 3 transactions v3, tips: 100, 200, 300
        // 1 transaction v1
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": {
                "block_hash": "0x1",
                "block_number": 111,
                "l1_da_mode": "BLOB",
                "l1_data_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l1_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "l2_gas_price": {
                    "price_in_fri": "0x1",
                    "price_in_wei": "0x1"
                },
                "new_root": "0x1",
                "parent_hash": "0x1",
                "sequencer_address": "0x1",
                "starknet_version": "0.14.0",
                "status": "ACCEPTED_ON_L2",
                "timestamp": 123,
                "transactions": [
                    {
                        "calldata": [],
                        "nonce": "0x1",
                        "max_fee":  "0x123",
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x1"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x64",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0xc8",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    },
                    {
                        "account_deployment_data": [],
                        "calldata": [],
                        "fee_data_availability_mode": "L1",
                        "nonce": "0x1",
                        "nonce_data_availability_mode": "L1",
                        "paymaster_data": [],
                        "resource_bounds": {
                            "l1_data_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l1_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            },
                            "l2_gas": {
                                "max_amount": "0x1",
                                "max_price_per_unit": "0x1"
                            }
                        },
                        "sender_address": "0x1",
                        "signature": [
                            "0x1",
                            "0x1"
                        ],
                        "tip": "0x12c",
                        "transaction_hash": "0x1",
                        "type": "INVOKE",
                        "version": "0x3"
                    }
                ]
            }
        }
        """.data(using: .utf8)!

        let session = makeMockedURLSession(data: json)
        let provider = StarknetProvider(url: "https://node.url", urlSession: session)

        let tip = try await estimateTip(provider: provider!)
        XCTAssertEqual(tip, UInt64AsHex(200))
    }
}
