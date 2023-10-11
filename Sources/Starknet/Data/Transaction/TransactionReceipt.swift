import Foundation

public struct StarknetTransactionReceipt: StarknetTransactionReceiptProtocol, Decodable {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let type: StarknetTransactionReceiptType
    public let messagesSent: [MessageToL1]
    public let revertReason: String?
    public let events: [StarknetEvent]
    public let contractAddress: Felt?

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case contractAddress = "contract_address"
        case executionStatus = "execution_status"
        case finalityStatus = "finality_status"
        case revertReason = "revert_reason"
        case type
        case events
    }
}

public struct StarknetPendingTransactionReceipt: StarknetTransactionReceiptProtocol, Decodable {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let type: StarknetTransactionReceiptType? = .pending
    public let messagesSent: [MessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let contractAddress: Felt?

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case messagesSent = "messages_sent"
        case contractAddress = "contract_address"
        case executionStatus = "execution_status"
        case finalityStatus = "finality_status"
        case revertReason = "revert_reason"
        case type
        case events
    }
}

public protocol StarknetTransactionReceiptProtocol: Decodable {
    var transactionHash: Felt { get }
    var actualFee: Felt { get }
    var messagesSent: [MessageToL1] { get }
    var events: [StarknetEvent] { get }
    var contractAddress: Felt? { get }
    var finalityStatus: StarknetTransactionFinalityStatus { get }
    var executionStatus: StarknetTransactionExecutionStatus { get }
    var revertReason: String? { get }

    var isSuccessful: Bool { get }
}
