import Foundation

public enum StarknetMerkleNode: Codable, Equatable {
    case binaryNode(StarknetBinaryNode)
    case edgeNode(StarknetEdgeNode)

    public init(from decoder: Decoder) throws {
        if let binaryNode = try? StarknetBinaryNode(from: decoder) {
            self = .binaryNode(binaryNode)
        } else if let edgeNode = try? StarknetEdgeNode(from: decoder) {
            self = .edgeNode(edgeNode)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Failed to decode StarknetMerkleNode."))
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

public struct StarknetBinaryNode: Codable, Equatable {
    let left: Felt
    let right: Felt

    enum CodingKeys: String, CodingKey, CaseIterable {
        case left
        case right
    }
}

public struct StarknetEdgeNode: Codable, Equatable {
    let path: NumAsHex
    let length: UInt
    let child: Felt

    enum CodingKeys: String, CodingKey, CaseIterable {
        case path
        case length
        case child
    }
}
