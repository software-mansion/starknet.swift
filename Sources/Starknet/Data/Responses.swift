import Foundation

public struct StarknetInvokeTransactionResponse: Decodable {
    public let transactionHash: Felt
    
    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

public struct StarknetEstimateFeeResponse: Decodable {
    public let gasConsumed: Felt
    public let gasPrice: Felt
    public let overallFee: Felt
    
    enum CodingKeys: String, CodingKey {
        case gasConsumed = "gas_consumed"
        case gasPrice = "gas_price"
        case overallFee = "overall_fee"
    }
}
