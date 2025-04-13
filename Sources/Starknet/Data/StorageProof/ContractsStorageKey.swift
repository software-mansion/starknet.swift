public struct ContractsStorageKeys: Encodable {
    let contractAddress: Felt
    let storageKeys: [Felt]

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case storageKeys = "storage_keys"
    }
}
