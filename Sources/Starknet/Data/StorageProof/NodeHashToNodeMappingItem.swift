public typealias NodeHashToNodeMapping = [NodeHashToNodeMappingItem]

public struct NodeHashToNodeMappingItem: Decodable, Equatable {
    public let nodeHash: Felt
    public let node: any MerkleNode

    enum CodingKeys: String, CodingKey {
        case nodeHash = "node_hash"
        case node
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodeHash = try container.decode(Felt.self, forKey: .nodeHash)

        let nodeContainer = try container.decode(NodeTypeContainer.self, forKey: .node)
        switch nodeContainer.type {
        case .binaryNode:
            node = try container.decode(BinaryNode.self, forKey: .node)
        case .edgeNode:
            node = try container.decode(EdgeNode.self, forKey: .node)
        }
    }

    public static func == (lhs: NodeHashToNodeMappingItem, rhs: NodeHashToNodeMappingItem) -> Bool {
        lhs.nodeHash == rhs.nodeHash && (try? lhs.node.isEqual(to: rhs.node)) ?? false
    }

    private struct NodeTypeContainer: Decodable {
        let type: NodeType

        enum NodeType: String, Decodable {
            case binaryNode = "BinaryNode"
            case edgeNode = "EdgeNode"
        }
    }
}
