import Foundation

public enum MerkleNode: Codable, Equatable {
    case binaryNode(BinaryNode)
    case edgeNode(EdgeNode)

    private enum CodingKeys: String, CodingKey {
        case left, right, path, length, child
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let binaryNodeKeys: Set<CodingKeys> = [.left, .right]
        let edgeNodeKeys: Set<CodingKeys> = [.path, .length, .child]

        let jsonKeys = Set(container.allKeys)

        if jsonKeys == binaryNodeKeys {
            let binaryNode = try BinaryNode(from: decoder)
            self = .binaryNode(binaryNode)
        } else if jsonKeys == edgeNodeKeys {
            let edgeNode = try EdgeNode(from: decoder)
            self = .edgeNode(edgeNode)
        } else {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid MerkleNode JSON object."
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
}

public struct BinaryNode: Codable, Equatable {
    let left: Felt
    let right: Felt

    enum CodingKeys: String, CodingKey {
        case left
        case right
    }
}

public struct EdgeNode: Codable, Equatable {
    let path: Int
    let length: Int
    let child: Felt

    enum CodingKeys: String, CodingKey {
        case path
        case length
        case child
    }
}
