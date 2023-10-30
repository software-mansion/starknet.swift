import Foundation

public struct StarknetMessageToL1: Decodable, Equatable {
    public let fromAddress: Felt
    public let toAddress: Felt
    public let payload: [Felt]

    enum CodingKeys: String, CodingKey {
        case fromAddress = "from_address"
        case toAddress = "to_address"
        case payload
    }
}

public struct StarknetMessageFromL1: Codable, Equatable {
    public let fromAddress: Felt
    public let toAddress: Felt
    public let entryPointSelector: Felt
    public let payload: [Felt]

    enum CodingKeys: String, CodingKey {
        case fromAddress = "from_address"
        case toAddress = "to_address"
        case entryPointSelector = "entry_point_selector"
        case payload
    }

    public init(fromAddress: Felt, toAddress: Felt, entryPointSelector: Felt, payload: [Felt]) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.entryPointSelector = entryPointSelector
        self.payload = payload
    }
}

public struct StarknetOrderedMessageToL1: Decodable, Equatable {
    public let order: Int
    public let fromAddress: Felt
    public let toAddress: Felt
    public let payload: [Felt]

    enum CodingKeys: String, CodingKey {
        case order
        case fromAddress = "from_address"
        case toAddress = "to_address"
        case payload
    }
}
