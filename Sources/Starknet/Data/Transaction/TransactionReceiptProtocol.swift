import Foundation

public protocol StarknetTransactionReceipt: StarknetTransactionReceiptProtocol {
    var transactionHash: Felt { get }
    var blockHash: Felt { get }
    var blockNumber: UInt64 { get }
    var actualFee: Felt { get }
    var messagesSent: [StarknetMessageToL1] { get }
    var events: [StarknetEvent] { get }
    var finalityStatus: StarknetTransactionFinalityStatus { get }
    var executionStatus: StarknetTransactionExecutionStatus { get }
    var executionResources: StarknetExecutionResources { get }
    var revertReason: String? { get }
    var type: StarknetTransactionType { get }

    var isSuccessful: Bool { get }
}

public protocol StarknetPendingTransactionReceipt: StarknetTransactionReceiptProtocol {
    var transactionHash: Felt { get }
    var actualFee: Felt { get }
    var messagesSent: [StarknetMessageToL1] { get }
    var events: [StarknetEvent] { get }
    var finalityStatus: StarknetTransactionFinalityStatus { get }
    var executionStatus: StarknetTransactionExecutionStatus { get }
    var executionResources: StarknetExecutionResources { get }
    var revertReason: String? { get }
    var type: StarknetTransactionType { get }

    var isSuccessful: Bool { get }
}

public protocol StarknetTransactionReceiptProtocol: Decodable {
    var transactionHash: Felt { get }
    var actualFee: Felt { get }
    var messagesSent: [StarknetMessageToL1] { get }
    var events: [StarknetEvent] { get }
    var finalityStatus: StarknetTransactionFinalityStatus { get }
    var executionStatus: StarknetTransactionExecutionStatus { get }
    var executionResources: StarknetExecutionResources { get }
    var revertReason: String? { get }
    var type: StarknetTransactionType { get }

    var isSuccessful: Bool { get }
}
