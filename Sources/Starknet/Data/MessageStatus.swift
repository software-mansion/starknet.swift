public struct MessageStatus: Decodable, Equatable {
    public let transactionHash: Felt
    public let finalityStatus: StarknetTransactionStatus
    public let failureReason: String?

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case finalityStatus = "finality_status"
        case failureReason = "failure_reason"
    }
}
