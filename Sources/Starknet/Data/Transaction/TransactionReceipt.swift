import Foundation

public struct StarknetInvokeTransactionReceipt: StarknetTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionReceiptType = .invoke

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

public struct StarknetPendingInvokeTransactionReceipt: StarknetPendingTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let type: StarknetTransactionReceiptType = .invoke

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

public struct StarknetDeclareTransactionReceipt: StarknetTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionReceiptType = .declare

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

public struct StarknetPendingDeclareTransactionReceipt: StarknetPendingTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let type: StarknetTransactionReceiptType = .declare

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

public struct StarknetDeployAccountTransactionReceipt: StarknetTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let contractAddress: Felt
    public let type: StarknetTransactionReceiptType = .deployAccount

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

public struct StarknetPendingDeployAccountTransactionReceipt: StarknetPendingTransactionReceipt, Decodable {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let contractAddress: Felt
    public let type: StarknetTransactionReceiptType = .deployAccount

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

public struct StarknetDeployTransactionReceipt: StarknetTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let contractAddress: Felt
    public let type: StarknetTransactionReceiptType = .deploy

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

public struct StarknetL1HandlerTransactionReceipt: StarknetTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let revertReason: String?
    public let finalityStatus: StarknetTransactionFinalityStatus
    public let executionStatus: StarknetTransactionExecutionStatus
    public let executionResources: StarknetExecutionResources
    public let messageHash: Felt
    public let type: StarknetTransactionReceiptType = .l1Handler

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

public struct StarknetPendingL1HandlerTransactionReceipt: StarknetPendingTransactionReceipt {
    public let transactionHash: Felt
    public let actualFee: Felt
    public let messagesSent: [StarknetMessageToL1]
    public let events: [StarknetEvent]
    public let executionStatus: StarknetTransactionExecutionStatus
    public let finalityStatus: StarknetTransactionFinalityStatus
    public var executionResources: StarknetExecutionResources
    public let revertReason: String?
    public let messageHash: Felt
    public let type: StarknetTransactionReceiptType = .l1Handler

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
