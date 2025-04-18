import Foundation

public protocol StarknetResources: Decodable, Equatable {
    var l1Gas: Int { get }
    var l2Gas: Int { get }
}

public struct StarknetExecutionResources: StarknetResources {
    public let l1Gas: Int
    public let l1DataGas: Int
    public let l2Gas: Int

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l1DataGas = "l1_data_gas"
        case l2Gas = "l2_gas"
    }
}

public struct StarknetInnerCallExecutionResources: StarknetResources {
    public let l1Gas: Int
    public let l2Gas: Int

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l2Gas = "l2_gas"
    }
}
