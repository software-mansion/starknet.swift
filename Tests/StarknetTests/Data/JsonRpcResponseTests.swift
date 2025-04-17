import XCTest

@testable import Starknet

final class JsonRpcResponseTests: XCTestCase {
    func testResponse() throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": 2137
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertNoThrow(try decoder.decode(JsonRpcResponse<Int>.self, from: json))
    }

    func testErrorWithoutData() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "error": {
                "code": 21,
                "message": "Invalid message selector"
            }
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<Int>.self, from: json)
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
    }

    func testErrorWithObjectData() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "error": {
                "code": -32603,
                "message": "Internal error",
                "data": {
                    "error": "Invalid message selector",
                    "details": {
                        "selector": "0x1234",
                        "number": 123
                    }
                }
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<Int>.self, from: json)
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
        XCTAssertNotNil(response.error!.data)
        let data = response.error!.data!
        XCTAssertTrue(data.contains("\"error\":\"Invalid message selector\""))
        XCTAssertTrue(data.contains("\"details\""))
        XCTAssertTrue(data.contains("\"selector\":\"0x1234\""))
        XCTAssertTrue(data.contains("\"number\":123"))
    }

    func testErrorWithStringData() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "error": {
                "code": 40,
                "message": "Contract error",
                "data": "More data about the execution failure."
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<Int>.self, from: json)
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
        XCTAssertNotNil(response.error!.data)
        let data = response.error!.data!
        XCTAssertEqual(data, "More data about the execution failure.")
    }

    func testErrorWithSequenceData() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "error": {
                "code": 40,
                "message": "Contract error",
                "data": [
                    "More data about the execution failure.",
                    "And even more data."
                ]
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<Int>.self, from: json)
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
        XCTAssertNotNil(response.error!.data)
        let data = response.error!.data!
        XCTAssertEqual(data, "[\"More data about the execution failure.\",\"And even more data.\"]")
    }

    func testBatchResponseWithIncorrectOrder() throws {
        let json = """
        [
            {
                "id": 1,
                "jsonrpc": "2.0",
                "result": 222
            },
            {
                "id": 2,
                "jsonrpc": "2.0",
                "result": 333
            },
            {
                "id": 0,
                "jsonrpc": "2.0",
                "result": 111
            }
        ]
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let responses = try decoder.decode([JsonRpcResponse<Int>].self, from: json)

        XCTAssertNotNil(responses[0].result)
        XCTAssertNotNil(responses[1].result)
        XCTAssertNotNil(responses[2].result)

        let orderedResponses = orderRpcResults(rpcResponses: responses)

        XCTAssertEqual(try orderedResponses[0].get(), 111)
        XCTAssertEqual(try orderedResponses[1].get(), 222)
        XCTAssertEqual(try orderedResponses[2].get(), 333)
    }

    // TODO(#225)
    func testGestMessagesStatusResponse() throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": [
                {
                    "transaction_hash": "0x123",
                    "finality_status": "ACCEPTED_ON_L2"
                },
                {
                    "transaction_hash": "0x123",
                    "finality_status": "ACCEPTED_ON_L2",
                    "failure_reason": "Example failure reason"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<[StarknetMessageStatus]>.self, from: json)
        let result = response.result

        XCTAssertEqual(result?.count, 2)

        XCTAssertEqual(result?[0].transactionHash, Felt(0x123))
        XCTAssertEqual(result?[0].finalityStatus, StarknetTransactionStatus.acceptedL2)
        XCTAssertNil(result?[0].failureReason)

        XCTAssertEqual(result?[1].transactionHash, Felt(0x123))
        XCTAssertEqual(result?[1].finalityStatus, StarknetTransactionStatus.acceptedL2)
        XCTAssertNotNil(result?[1].failureReason)
    }

    func testGetStorageProofResponse() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "result": {
                "classes_proof": [
                    {"node": {"left": "0x123", "right": "0x123"}, "node_hash": "0x123"},
                    {
                        "node": {"child": "0x123", "length": 2, "path": "0x123"},
                        "node_hash": "0x123"
                    }
                ],
                "contracts_proof": {
                    "contract_leaves_data": [
                        {"class_hash": "0x123", "nonce": "0x0", "storage_root": "0x123"}
                    ],
                    "nodes": [
                        {
                            "node": {"left": "0x123", "right": "0x123"},
                            "node_hash": "0x123"
                        },
                        {
                            "node": {"child": "0x123", "length": 232, "path": "0x123"},
                            "node_hash": "0x123"
                        }
                    ]
                },
                "contracts_storage_proofs": [
                    [
                        {
                            "node": {"left": "0x123", "right": "0x123"},
                            "node_hash": "0x123"
                        },
                        {
                            "node": {"child": "0x123", "length": 123, "path": "0x123"},
                            "node_hash": "0x123"
                        },
                        {
                            "node": {"left": "0x123", "right": "0x123"},
                            "node_hash": "0x123"
                        }
                    ]
                ],
                "global_roots": {
                    "block_hash": "0x123",
                    "classes_tree_root": "0x456",
                    "contracts_tree_root": "0x789"
                }
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<StarknetGetStorageProofResponse>.self, from: json)
        let result = response.result

        XCTAssertEqual(result?.classesProof.count, 2)
        XCTAssertEqual(result?.contractsProof.nodes.count, 2)
        XCTAssertEqual(result?.contractsStorageProofs.count, 1)
        XCTAssertEqual(result?.globalRoots.blockHash, Felt(0x123))
        XCTAssertEqual(result?.globalRoots.classesTreeRoot, Felt(0x456))
        XCTAssertEqual(result?.globalRoots.contractsTreeRoot, Felt(0x789))
    }
}
