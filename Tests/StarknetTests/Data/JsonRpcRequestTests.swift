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

final class JsonRpcRequestTests: XCTestCase {
    func testGetMessagesStatusRequest() throws {
        let hash = NumAsHex(0x123)
        let params = GetMessagesStatusParams(transactionHash: hash)

        let encoder = JSONEncoder()
        let data = try encoder.encode(params)
        let json = String(data: data, encoding: .utf8)

        let expected = #"{"transaction_hash":"0x123"}"#
        XCTAssertEqual(json, expected)
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
