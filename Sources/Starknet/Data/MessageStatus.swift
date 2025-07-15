public struct StarknetMessageStatus: Decodable, Equatable {
    public let transactionHash: Felt
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let failureReason: String?
    public let executionStatus: StarknetTransactionExecutionStatus

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case finalityStatus = "finality_status"
        case failureReason = "failure_reason"
        case executionStatus = "execution_status"
    }
}
