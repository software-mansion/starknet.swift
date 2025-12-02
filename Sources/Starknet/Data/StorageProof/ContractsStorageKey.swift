public struct StarknetContractsStorageKeys: Encodable {
    let contractAddress: Felt
    let storageKeys: [StarknetStorageKey]

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case storageKeys = "storage_keys"
    }
}

public struct StarknetStorageKey: Encodable {
    let value: String
    static let regex = #/^0x(0|[0-7]{1}[a-fA-F0-9]{0,62}$)/#

    public init?(_ value: String) {
        guard value.wholeMatch(of: StarknetStorageKey.regex) != nil else {
            return nil
        }

        self.value = value
    }

    public init?(fromFelt felt: Felt) {
        self.init(felt.toHex())
    }

    public func encode(to encoder: any Encoder) throws {
        try self.value.encode(to: encoder)
    }
}
