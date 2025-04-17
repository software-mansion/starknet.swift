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
}
