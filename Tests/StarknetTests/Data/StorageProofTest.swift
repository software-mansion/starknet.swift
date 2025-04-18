import XCTest

@testable import Starknet

// We need to compare the parsed JSON structures rather than raw strings because JSONEncoder
// does not guarantee key order in the output, hence comparing JSON strings directly is unreliable.
func XCTAssertEqualJSON(_ json1: String, _ json2: String, file: StaticString = #file, line: UInt = #line) {
    guard
        let data1 = json1.data(using: .utf8),
        let data2 = json2.data(using: .utf8),
        let obj1 = try? JSONSerialization.jsonObject(with: data1, options: []),
        let obj2 = try? JSONSerialization.jsonObject(with: data2, options: [])
    else {
        XCTFail("Failed to parse JSON", file: file, line: line)
        return
    }

    XCTAssertEqual(obj1 as? NSDictionary, obj2 as? NSDictionary, file: file, line: line)
}

final class StorageProofTests: XCTestCase {
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

    func testGetStorageProofRequest() throws {
        let blockId = StarknetBlockId.tag(.latest)
        let classHashes = [Felt(0x12), Felt(0x34)]
        let contractAddresses = [Felt(0x56), Felt(0x78)]
        let contractsStorageKeys = [
            StarknetContractsStorageKeys(contractAddress: Felt(0x11), storageKeys: [Felt(0x22), Felt(0x33)]),
            StarknetContractsStorageKeys(contractAddress: Felt(0x44), storageKeys: [Felt(0x55), Felt(0x66)]),
        ]

        let params = GetStorageProofParams(blockId: blockId, classHashes: classHashes, contractAddresses: contractAddresses, contractsStorageKeys: contractsStorageKeys)
        let encoder = JSONEncoder()
        let data = try encoder.encode(params)
        let json = String(data: data, encoding: .utf8)!
        let expected = #"{"contract_addresses":["0x56","0x78"],"class_hashes":["0x12","0x34"],"block_id":"latest","contracts_storage_keys":[{"contract_address":"0x11","storage_keys":["0x22","0x33"]},{"contract_address":"0x44","storage_keys":["0x55","0x66"]}]}"#

        XCTAssertEqualJSON(json, expected)
    }
}
