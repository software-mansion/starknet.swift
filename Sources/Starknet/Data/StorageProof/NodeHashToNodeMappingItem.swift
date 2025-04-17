public typealias StarknetNodeHashToNodeMapping = [StarknetStarknetNodeHashToNodeMappingItem]

public struct StarknetStarknetNodeHashToNodeMappingItem: Decodable, Equatable {
    public let nodeHash: Felt
    public let node: StarknetMerkleNode

    enum CodingKeys: String, CodingKey {
        case nodeHash = "node_hash"
        case node
    }
}
