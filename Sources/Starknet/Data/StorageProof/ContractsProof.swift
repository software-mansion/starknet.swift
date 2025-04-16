public struct StarknetContractsProof: Decodable, Equatable {
    public let nodes: NodeHashToNodeMapping
    public let contractLeavesData: [ContractLeafData]

    enum CodingKeys: String, CodingKey {
        case nodes
        case contractLeavesData = "contract_leaves_data"
    }

    public struct StarknetContractLeafData: Decodable, Equatable {
        public let nonce: Felt
        public let classHash: Felt
        public let storageRoot: Felt?

        enum CodingKeys: String, CodingKey {
            case nonce
            case classHash = "class_hash"
            case storageRoot = "storage_root"
        }
    }
}
