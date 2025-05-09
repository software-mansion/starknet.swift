import Foundation

public struct StarknetResourceBounds: Codable, Equatable, Hashable {
    public let maxAmount: UInt64AsHex
    public let maxPricePerUnit: UInt128AsHex

    public static let zero = StarknetResourceBounds(
        maxAmount: .zero,
        maxPricePerUnit: .zero
    )

    public init(maxAmount: UInt64AsHex, maxPricePerUnit: UInt128AsHex) {
        self.maxAmount = maxAmount
        self.maxPricePerUnit = maxPricePerUnit
    }

    enum CodingKeys: String, CodingKey {
        case maxAmount = "max_amount"
        case maxPricePerUnit = "max_price_per_unit"
    }
}

public struct StarknetResourceBoundsMapping: Codable, Equatable, Hashable {
    public let l1Gas: StarknetResourceBounds
    public let l2Gas: StarknetResourceBounds
    public let l1DataGas: StarknetResourceBounds

    public static let zero = StarknetResourceBoundsMapping(
        l1Gas: StarknetResourceBounds.zero,
        l2Gas: StarknetResourceBounds.zero,
        l1DataGas: StarknetResourceBounds.zero
    )

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l2Gas = "l2_gas"
        case l1DataGas = "l1_data_gas"
    }
}
