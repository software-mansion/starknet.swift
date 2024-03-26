import Foundation

public protocol StarknetInvokeTransactionReceiptProtocol: StarknetTransactionReceipt {}

public protocol StarknetDeclareTransactionReceiptProtocol: StarknetTransactionReceipt {}

public protocol StarknetDeployTransactionReceiptProtocol: StarknetTransactionReceipt {
    var contractAddress: Felt { get }
}

public protocol StarknetDeployAccountTransactionReceiptProtocol: StarknetTransactionReceipt {
    var contractAddress: Felt { get }
}

public protocol StarknetL1HandlerTransactionReceiptProtocol: StarknetTransactionReceipt {
    var messageHash: NumAsHex { get }
}

public protocol StarknetTransactionReceipt: Decodable, Equatable {
    var transactionHash: Felt { get }
    var actualFee: StarknetFeePayment { get }
    var messagesSent: [StarknetMessageToL1] { get }
    var events: [StarknetEvent] { get }
    var finalityStatus: StarknetTransactionFinalityStatus { get }
    var executionStatus: StarknetTransactionExecutionStatus { get }
    var executionResources: StarknetExecutionResources { get }
    var revertReason: String? { get }
    var type: StarknetTransactionType { get }
    // Block info
    var blockHash: Felt? { get }
    var blockNumber: UInt64? { get }

    var isSuccessful: Bool { get }
}
