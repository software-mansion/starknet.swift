import Foundation

public protocol StarknetResources: Decodable, Equatable {
    var l1Gas: UInt { get }
    var l2Gas: UInt { get }
}

public struct StarknetExecutionResources: StarknetResources {
    public let l1Gas: UInt
    public let l1DataGas: UInt
    public let l2Gas: UInt

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l1DataGas = "l1_data_gas"
        case l2Gas = "l2_gas"
    }
}

public struct StarknetInnerCallExecutionResources: StarknetResources {
    public let l1Gas: UInt
    public let l2Gas: UInt

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l2Gas = "l2_gas"
    }
}
