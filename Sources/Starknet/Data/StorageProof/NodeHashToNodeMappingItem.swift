public typealias NodeHashToNodeMapping = [NodeHashToNodeMappingItem]

public struct NodeHashToNodeMappingItem: Decodable, Equatable {
    public let nodeHash: Felt
    public let node: MerkleNode

    enum CodingKeys: String, CodingKey {
        case nodeHash = "node_hash"
        case node
    }

    public static func == (lhs: NodeHashToNodeMappingItem, rhs: NodeHashToNodeMappingItem) -> Bool {
        lhs.nodeHash == rhs.nodeHash && lhs.node == rhs.node
    }
}
