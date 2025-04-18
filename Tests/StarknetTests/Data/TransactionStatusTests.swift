import XCTest

@testable import Starknet

final class TransactionStatusTests: XCTestCase {
    func testGetTransactionStatusResponse() async throws {
        let json = """
        {"finality_status":"REJECTED"}
        """.data(using: .utf8)!
        let json2 = """
        {"finality_status":"ACCEPTED_ON_L2","execution_status":"SUCCEEDED"}
        """.data(using: .utf8)!
        let json3 = """
        {"finality_status":"ACCEPTED_ON_L2","execution_status":"SUCCEEDED","failure_reason": "xyz"}
        """.data(using: .utf8)!
        let invalidJson = """
        {"finality_status":"INVALID_STATUS"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let status = try decoder.decode(StarknetGetTransactionStatusResponse.self, from: json)
        XCTAssertNil(status.executionStatus)
        XCTAssertNil(status.failureReason)

        let status2 = try decoder.decode(StarknetGetTransactionStatusResponse.self, from: json2)
        XCTAssertNotNil(status2.executionStatus)
        XCTAssertNil(status2.failureReason)

        let status3 = try decoder.decode(StarknetGetTransactionStatusResponse.self, from: json3)
        XCTAssertNotNil(status3.executionStatus)
        XCTAssertNotNil(status3.failureReason)

        XCTAssertThrowsError(try decoder.decode(StarknetGetTransactionStatusResponse.self, from: invalidJson))
    }
}
