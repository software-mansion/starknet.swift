import Foundation

public struct StarknetFeePayment: Decodable, Equatable {
    public let amount: Felt
    public let feeUnit: StarknetPriceUnit

    enum CodingKeys: String, CodingKey {
        case amount
        case feeUnit = "unit"
    }
}
