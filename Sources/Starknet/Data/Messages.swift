import Foundation

public struct MessageToL1: Decodable, Equatable {
    public let fromAddress: Felt
    public let toAddress: Felt
    public let payload: [Felt]

    enum CodingKeys: String, CodingKey {
        case fromAddress = "from_address"
        case toAddress = "to_address"
        case payload
    }
}

public struct MessageFromL1: Codable, Equatable {
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
}
