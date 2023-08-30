import Foundation

public struct StarknetCommonTransactionReceipt: StarknetTransactionReceipt, Decodable {
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transactionHash = try container.decode(Felt.self, forKey: .transactionHash)
        self.actualFee = try container.decode(Felt.self, forKey: .actualFee)
        self.blockHash = try container.decode(Felt.self, forKey: .blockHash)
        self.blockNumber = try container.decode(UInt64.self, forKey: .blockNumber)
        self.messagesSent = try container.decode([MessageToL1].self, forKey: .messagesSent)
        self.contractAddress = try container.decodeIfPresent(Felt.self, forKey: .contractAddress)
        self.executionStatus = try container.decode(StarknetTransactionExecutionStatus.self, forKey: .executionStatus)
        self.finalityStatus = try container.decode(StarknetTransactionFinalityStatus.self, forKey: .finalityStatus)
        self.type = try container.decode(StarknetTransactionReceiptType.self, forKey: .type)
        self.events = try container.decode([StarknetEvent].self, forKey: .events)
        self.revertReason = try container.decodeIfPresent(String.self, forKey: .revertReason)
    }
}

public struct StarknetPendingTransactionReceipt: StarknetTransactionReceipt, Decodable {
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transactionHash = try container.decode(Felt.self, forKey: .transactionHash)
        self.actualFee = try container.decode(Felt.self, forKey: .actualFee)
        self.messagesSent = try container.decode([MessageToL1].self, forKey: .messagesSent)
        self.contractAddress = try container.decodeIfPresent(Felt.self, forKey: .contractAddress)
        self.executionStatus = try container.decode(StarknetTransactionExecutionStatus.self, forKey: .executionStatus)
        self.finalityStatus = try container.decode(StarknetTransactionFinalityStatus.self, forKey: .finalityStatus)
        self.events = try container.decode([StarknetEvent].self, forKey: .events)
        self.revertReason = try container.decodeIfPresent(String.self, forKey: .revertReason)
    }
}

public protocol StarknetTransactionReceipt: Decodable {
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
