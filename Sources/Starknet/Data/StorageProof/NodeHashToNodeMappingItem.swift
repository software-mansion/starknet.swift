public typealias NodeHashToNodeMapping = [Starknet NodeHashToNodeMappingItem]

public struct Starknet NodeHashToNodeMappingItem: Decodable, Equatable {
    public let nodeHash: Felt
    public let node: StarknetMerkleNode

    enum CodingKeys: String, CodingKey {
        case nodeHash = "node_hash"
        case node
    }
}
