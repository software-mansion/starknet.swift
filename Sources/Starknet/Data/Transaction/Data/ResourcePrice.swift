public struct StarknetResourcePrice: Codable, Equatable {
    public let priceInWei: Felt
    public let priceInFri: Felt

    enum CodingKeys: String, CodingKey {
        case priceInWei = "price_in_wei"
        case priceInFri = "price_in_fri"
    }
}
