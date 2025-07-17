public struct StarknetMessageStatus: Decodable, Equatable {
    public let transactionHash: Felt
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let failureReason: String?

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case failureReason = "failure_reason"
    }
}
