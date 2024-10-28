public typealias NodeHashToNodeMapping = [NodeHashToNodeMappingItem]

public struct NodeHashToNodeMappingItem: Decodable, Equatable {
    public let nodeHash: Felt
    public let node: MerkleNode

    enum CodingKeys: String, CodingKey {
        case nodeHash = "node_hash"
        case node
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        nodeHash = try container.decode(Felt.self, forKey: .nodeHash)
        node = try container.decode(MerkleNode.self, forKey: .node)
    }

    public static func == (lhs: NodeHashToNodeMappingItem, rhs: NodeHashToNodeMappingItem) -> Bool {
        lhs.nodeHash == rhs.nodeHash && lhs.node == rhs.node
    }
}
