import Foundation

public protocol StarknetInvokeTransactionReceipt: StarknetTransactionReceipt {}

public protocol StarknetDeclareTransactionReceipt: StarknetTransactionReceipt {}

public protocol StarknetDeployTransactionReceipt: StarknetTransactionReceipt {
    var contractAddress: Felt { get }
}

public protocol StarknetDeployAccountTransactionReceipt: StarknetTransactionReceipt {
    var contractAddress: Felt { get }
}

public protocol StarknetL1HandlerTransactionReceipt: StarknetTransactionReceipt {
    var messageHash: NumAsHex { get }
}

public protocol StarknetProcessedTransactionReceipt: StarknetTransactionReceipt {
    var blockHash: Felt { get }
    var blockNumber: UInt64 { get }
}

public protocol StarknetPendingTransactionReceipt: StarknetTransactionReceipt {}

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

    var isSuccessful: Bool { get }
}
