import Foundation

public struct MessageToL1: Decodable, Equatable {
    public let toAddress: Felt
    public let payload: Felt

    enum CodingKeys: String, CodingKey {
        case toAddress = "to_address"
        case payload
    }
}

/// Message from L1
///
/// - Parameters:
///  - fromAddress: The address of the L1 contract sending the message
///  - toAddress: The target L2 address the message is sent to
///  - payload: The payload of the message
public struct MessageFromL1: Codable, Equatable {
    public let fromAddress: Felt
    public let toAddress: Felt
    public let payload: [Felt]

    enum CodingKeys: String, CodingKey {
        case fromAddress = "from_address"
        case toAddress = "to_address"
        case payload
    }
}
