import Foundation

public typealias Calldata = [Felt]

public struct Call: Codable {
    public let contractAddress: Felt
    public let entrypoint: Felt
    public let calldata: Calldata
    
    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case entrypoint
        case calldata
    }
}
