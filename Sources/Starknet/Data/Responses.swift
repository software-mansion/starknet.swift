import Foundation

public struct StarknetInvokeTransactionResponse: Decodable {
    public let transactionHash: Felt
    
    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}
