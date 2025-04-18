public struct StarknetGlobalRoots: Decodable, Equatable {
    public let contractsTreeRoot: Felt
    public let classesTreeRoot: Felt
    public let blockHash: Felt

    enum CodingKeys: String, CodingKey {
        case contractsTreeRoot = "contracts_tree_root"
        case classesTreeRoot = "classes_tree_root"
        case blockHash = "block_hash"
    }
}
