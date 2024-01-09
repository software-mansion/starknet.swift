import Foundation

public struct StarknetResourceBoundsResourceBounds {
    public let maxAmount: UInt64
    public let maxPricePerUnit: UInt128AsHex

    enum CodingKeys: String, CodingKey {
        case maxAmount = "max_amount"
        case maxPricePerUnit = "max_price_per_unit"
    }
}

public struct StarknetResourceBoundsResourceBoundsMapping {
    public let l1Gas: StarknetResourceBoundsResourceBounds
    public let l2Gas: StarknetResourceBoundsResourceBounds

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l2Gas = "l2_gas"
    }
}
