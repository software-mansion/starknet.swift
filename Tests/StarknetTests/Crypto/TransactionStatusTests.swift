import XCTest

@testable import Starknet

final class TransactionStatusTests: XCTestCase {
    func testGetTransactionStatusResponse() async throws {
        let json = """
        {"jsonrpc":"2.0","result":"REJECTED","id":0}
        """.data(using: .utf8)!
        let invalidJson = """
        {"jsonrpc":"2.0","result":"INVALID_STATUS","id":0}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertNoThrow(try decoder.decode(JsonRpcResponse<StarknetGatewayTransactionStatus>.self, from: json))
        XCTAssertThrowsError(try decoder.decode(JsonRpcResponse<StarknetGatewayTransactionStatus>.self, from: invalidJson))
    }
}
