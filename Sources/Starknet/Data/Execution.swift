import Foundation

public typealias StarknetCalldata = [Felt]

public struct StarknetCall: Codable {
    public let contractAddress: Felt
    public let entrypoint: Felt
    public let calldata: StarknetCalldata
    
    public init(contractAddress: Felt, entrypoint: Felt, calldata: StarknetCalldata) {
        self.contractAddress = contractAddress
        self.entrypoint = entrypoint
        self.calldata = calldata
    }

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case entrypoint = "entry_point_selector"
        case calldata
    }
}
