import XCTest

@testable import Starknet

final class MessagesStatusTests: XCTestCase {
    // TODO(#225)
    func testGetMessagesStatusResponse() throws {
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

    func testGetMessagesStatusRequest() throws {
        let hash = NumAsHex(0x123)
        let params = GetMessagesStatusParams(transactionHash: hash)

        let encoder = JSONEncoder()
        let data = try encoder.encode(params)
        let json = String(data: data, encoding: .utf8)

        let expected = #"{"transaction_hash":"0x123"}"#
        XCTAssertEqual(json, expected)
    }
}
