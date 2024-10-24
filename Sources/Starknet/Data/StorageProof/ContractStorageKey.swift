public struct ContractStorageKey: Encodable {
    let contractAddress: Felt
    let key: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case key
    }
}
