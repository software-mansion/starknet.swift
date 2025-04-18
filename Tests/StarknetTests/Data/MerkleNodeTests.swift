import XCTest

@testable import Starknet

final class StarknetMerkleNodeTests: XCTestCase {
    func testStarknetBinaryNode() throws {
        let json = """
        {
            "left": "0x123",
            "right": "0x456"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let node = try decoder.decode(StarknetMerkleNode.self, from: json)

        if case let .binaryNode(binaryNode) = node {
            XCTAssertEqual(binaryNode.left, Felt(0x123))
            XCTAssertEqual(binaryNode.right, Felt(0x456))
        } else {
            XCTFail("Expected a binaryNode, but got \(node)")
        }
    }

    func testInvalidStarknetBinaryNode() throws {
        let json = """
        {
            "left": "0x123"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(StarknetMerkleNode.self, from: json))
    }

    func testStarknetEdgeNode() throws {
        let json = """
        {
            "path": "0x123",
            "length": 456,
            "child": "0x789"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let node = try decoder.decode(StarknetMerkleNode.self, from: json)
        if case let .edgeNode(edgeNode) = node {
            XCTAssertEqual(edgeNode.path, 291)
            XCTAssertEqual(edgeNode.length, 456)
            XCTAssertEqual(edgeNode.child, Felt("0x789"))
        } else {
            XCTFail("Expected an edgeNode, but got \(node)")
        }
    }

    func testInvalidStarknetEdgeNode() throws {
        let json = """
        {
            "path": "0x123",
            "length": 456
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(StarknetMerkleNode.self, from: json))
    }

    func testInvalidNodeWithMixedKeys() throws {
        let json = """
        {
            "path": "0x123",
            "length": "456",
            "left": 10
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertThrowsError(try decoder.decode(StarknetMerkleNode.self, from: json))
    }
}
