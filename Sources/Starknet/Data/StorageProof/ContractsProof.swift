public struct ContractsProof: Decodable, Equatable {
    public let nodes: NodeHashToNodeMapping
    public let contractLeavesData: [ContractLeafData]

    enum CodingKeys: String, CodingKey {
        case nodes
        case contractLeavesData = "contract_leaves_data"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nodes = try container.decode(NodeHashToNodeMapping.self, forKey: .nodes)
        contractLeavesData = try container.decode([ContractLeafData].self, forKey: .contractLeavesData)
    }

    public static func == (lhs: ContractsProof, rhs: ContractsProof) -> Bool {
        lhs.nodes == rhs.nodes && lhs.contractLeavesData == rhs.contractLeavesData
    }

    public struct ContractLeafData: Decodable, Equatable {
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
