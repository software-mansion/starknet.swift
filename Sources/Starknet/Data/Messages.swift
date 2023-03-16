import Foundation

public struct MessageToL1: Decodable, Equatable {
    public let toAddress: Felt
    public let payload: Felt

    enum CodingKeys: String, CodingKey {
        case toAddress = "to_address"
        case payload
    }
}
