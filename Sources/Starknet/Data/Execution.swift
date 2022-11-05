import Foundation

typealias Calldata = [Felt]

struct Call: Codable {
    let contractAddress: Felt
    let entrypoint: Felt
    let calldata: Calldata
    
    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case entrypoint
        case calldata
    }
}
