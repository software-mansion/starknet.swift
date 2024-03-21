import Foundation

public struct StarknetInvokeTransactionReceiptWithBlockInfo: StarknetTransactionReceiptWithBlockInfo, StarknetInvokeTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionType = .invoke

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case revertReason = "revert_reason"
        case executionResources = "execution_resources"
    }
}

public struct StarknetInvokeTransactionReceipt: StarknetInvokeTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let type: StarknetTransactionType = .invoke

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case executionResources = "execution_resources"
        case revertReason = "revert_reason"
    }
}

public struct StarknetDeclareTransactionReceiptWithBlockInfo: StarknetTransactionReceiptWithBlockInfo, StarknetDeclareTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionType = .declare

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case revertReason = "revert_reason"
        case executionResources = "execution_resources"
    }
}

public struct StarknetDeclareTransactionReceipt: StarknetDeclareTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let type: StarknetTransactionType = .declare

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case executionResources = "execution_resources"
        case revertReason = "revert_reason"
    }
}

public struct StarknetDeployAccountTransactionReceiptWithBlockInfo: StarknetTransactionReceiptWithBlockInfo, StarknetDeployAccountTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let contractAddress: Felt
    public let type: StarknetTransactionType = .deployAccount

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case revertReason = "revert_reason"
        case executionResources = "execution_resources"
        case contractAddress = "contract_address"
    }
}

public struct StarknetDeployAccountTransactionReceipt: StarknetDeployAccountTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let contractAddress: Felt
    public let type: StarknetTransactionType = .deployAccount

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case executionResources = "execution_resources"
        case revertReason = "revert_reason"
        case contractAddress = "contract_address"
    }
}

public struct StarknetDeployTransactionReceipt: StarknetDeployTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let contractAddress: Felt
    public let type: StarknetTransactionType = .deploy

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case revertReason = "revert_reason"
        case executionResources = "execution_resources"
        case contractAddress = "contract_address"
    }
}

public struct StarknetDeployTransactionReceiptWithBlockInfo: StarknetTransactionReceiptWithBlockInfo, StarknetDeployTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let contractAddress: Felt
    public let type: StarknetTransactionType = .deploy

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case revertReason = "revert_reason"
        case executionResources = "execution_resources"
        case contractAddress = "contract_address"
    }
}

public struct StarknetL1HandlerTransactionReceiptWithBlockInfo: StarknetTransactionReceiptWithBlockInfo, StarknetL1HandlerTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let messageHash: NumAsHex
    public let type: StarknetTransactionType = .l1Handler

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case revertReason = "revert_reason"
        case executionResources = "execution_resources"
        case messageHash = "message_hash"
    }
}

public struct StarknetL1HandlerTransactionReceipt: StarknetL1HandlerTransactionReceiptProtocol {
    public let transactionHash: Felt
    public let actualFee: StarknetFeePayment
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let messageHash: NumAsHex
    public let type: StarknetTransactionType = .l1Handler

    public var isSuccessful: Bool {
        executionStatus == .succeeded && (finalityStatus == .acceptedL1 || finalityStatus == .acceptedL2)
    }

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case actualFee = "actual_fee"
        case messagesSent = "messages_sent"
        case events
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case executionResources = "execution_resources"
        case revertReason = "revert_reason"
        case messageHash = "message_hash"
    }
}
