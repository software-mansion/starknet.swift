import Foundation

public struct StarknetStorageDiffItem: Decodable, Equatable {
    public let key: Felt
    public let value: Felt

    enum CodingKeys: String, CodingKey {
        case key
        case value
    }
}

public struct StarknetContractStorageDiffItem: Decodable, Equatable {
    public let address: Felt
    public let storageEntries: [StarknetStorageDiffItem]

    enum CodingKeys: String, CodingKey {
        case address
        case storageEntries = "storage_entries"
    }
}

public struct StarknetDeclaredClassItem: Decodable, Equatable {
    public let classHash: Felt
    public let compiledClassHash: Felt

    enum CodingKeys: String, CodingKey {
        case classHash = "class_hash"
        case compiledClassHash = "compiled_class_hash"
    }
}

public struct StarknetDeployedContractItem: Decodable, Equatable {
    public let address: Felt
    public let classHash: Felt

    enum CodingKeys: String, CodingKey {
        case address
        case classHash = "class_hash"
    }
}

public struct StarknetReplacedClassItem: Decodable, Equatable {
    public let contractAddress: Felt
    public let classHash: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case classHash = "class_hash"
    }
}

public struct StarknetNonceUpdateItem: Decodable, Equatable {
    public let contractAddress: Felt
    public let nonce: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case nonce
    }
}
