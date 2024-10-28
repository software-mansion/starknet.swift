import Foundation

public enum MerkleNode: Codable, Equatable {
    case binaryNode(BinaryNode)
    case edgeNode(EdgeNode)

    public init(from decoder: Decoder) throws {
        let binaryNodeKeys = Set(BinaryNode.CodingKeys.allCases.map(\.stringValue))
        let edgeNodeKeys = Set(EdgeNode.CodingKeys.allCases.map(\.stringValue))

        let binaryNodeContainer = try decoder.container(keyedBy: BinaryNode.CodingKeys.self)

        if Set(binaryNodeContainer.allKeys.map(\.stringValue)) == binaryNodeKeys {
            let binaryNode = try BinaryNode(from: decoder)
            self = .binaryNode(binaryNode)
        } else if let edgeNodeContainer = try? decoder.container(keyedBy: EdgeNode.CodingKeys.self),
                  Set(edgeNodeContainer.allKeys.map(\.stringValue)) == edgeNodeKeys
        {
            let edgeNode = try EdgeNode(from: decoder)
            self = .edgeNode(edgeNode)
        } else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                // TODO: Improve error message.
                debugDescription: "Failed to decode MerkleNode from the given data."
            )
            throw DecodingError.dataCorrupted(context)
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

    public static func == (lhs: MerkleNode, rhs: MerkleNode) -> Bool {
        switch (lhs, rhs) {
        case let (.binaryNode(lhsBinaryNode), .binaryNode(rhsBinaryNode)):
            lhsBinaryNode == rhsBinaryNode
        case let (.edgeNode(lhsEdgeNode), .edgeNode(rhsEdgeNode)):
            lhsEdgeNode == rhsEdgeNode
        default:
            false
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
    let path: Int
    let length: Int
    let child: Felt

    enum CodingKeys: String, CodingKey, CaseIterable {
        case path
        case length
        case child
    }
}
