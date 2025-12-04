public struct StarknetContractsStorageKeys: Encodable {
    let contractAddress: Felt
    let storageKeys: [StarknetStorageKey]

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case storageKeys = "storage_keys"
    }
}

/// A storage key. Represented as up to 62 hex digits, 3 bits, and 5 leading zeroes.
/// Storage keys must be a hexidecimal string, starting with `0x`, conforming to the regex `#/^0x(0|[0-7]{1}[a-fA-F0-9]{0,62}$)/#`
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
