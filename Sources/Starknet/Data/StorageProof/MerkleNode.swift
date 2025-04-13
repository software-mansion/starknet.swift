import Foundation

public enum MerkleNode: Codable, Equatable {
    case binaryNode(BinaryNode)
    case edgeNode(EdgeNode)

    public init(from decoder: Decoder) throws {
        if let binaryNode = try? BinaryNode(from: decoder) {
            self = .binaryNode(binaryNode)
        } else if let edgeNode = try? EdgeNode(from: decoder) {
            self = .edgeNode(edgeNode)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode MerkleNode."))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case let .binaryNode(binaryNode):
            try container.encode(binaryNode)
        case let .edgeNode(edgeNode):
            try container.encode(edgeNode)
        }
    }
}

public struct BinaryNode: Codable, Equatable {
    let left: Felt
    let right: Felt

    enum CodingKeys: String, CodingKey, CaseIterable {
        case left
        case right
    }
}

public struct EdgeNode: Codable, Equatable {
    let path: NumAsHex
    let length: Int
    let child: Felt

    enum CodingKeys: String, CodingKey, CaseIterable {
        case path
        case length
        case child
    }
}
