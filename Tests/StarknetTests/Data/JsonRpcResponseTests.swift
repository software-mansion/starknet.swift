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

    func testError() async throws {
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

    func testErrorWithData() async throws {
        let json = """
        {
            "id": 0,
            "jsonrpc": "2.0",
            "error": {
                "code": 40,
                "message": "Contract error",
                "data": {
                    "revert_error": "More data about the execution failure."
                }
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let response = try decoder.decode(JsonRpcResponse<Int>.self, from: json)
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
        XCTAssertNotNil(response.error!.data)
    }
}
