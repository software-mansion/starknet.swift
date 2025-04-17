import XCTest

@testable import Starknet

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

    // TODO: Add testGetStorageProofRequest
}
