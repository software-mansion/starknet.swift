import Foundation

enum TransactionReceiptWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case type
    }

    case invoke(StarknetProcessedInvokeTransactionReceipt)
    case declare(StarknetProcessedDeclareTransactionReceipt)
    case deployAccount(StarknetProcessedDeployAccountTransactionReceipt)
    case l1Handler(StarknetProcessedL1HandlerTransactionReceipt)
    case deploy(StarknetProcessedDeployTransactionReceipt)
    case pendingInvoke(StarknetPendingInvokeTransactionReceipt)
    case pendingDeclare(StarknetPendingDeclareTransactionReceipt)
    case pendingDeployAccount(StarknetPendingDeployAccountTransactionReceipt)
    case pendingL1Handler(StarknetPendingL1HandlerTransactionReceipt)

    public var transactionReceipt: any StarknetTransactionReceipt {
        switch self {
        case let .invoke(tx):
            return tx
        case let .declare(tx):
            return tx
        case let .deployAccount(tx):
            return tx
        case let .l1Handler(tx):
            return tx
        case let .deploy(tx):
            return tx
        case let .pendingInvoke(tx):
            return tx
        case let .pendingDeclare(tx):
            return tx
        case let .pendingDeployAccount(tx):
            return tx
        case let .pendingL1Handler(tx):
            return tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)
        let blockHash = try container.decodeIfPresent(Felt.self, forKey: Keys.blockHash)
        let blockNumber = try container.decodeIfPresent(Felt.self, forKey: Keys.blockHash)

        let isPending = blockHash == nil || blockNumber == nil

        switch (type, isPending) {
        case (.invoke, false):
            self = try .invoke(StarknetProcessedInvokeTransactionReceipt(from: decoder))
        case (.declare, false):
            self = try .declare(StarknetProcessedDeclareTransactionReceipt(from: decoder))
        case (.deployAccount, false):
            self = try .deployAccount(StarknetProcessedDeployAccountTransactionReceipt(from: decoder))
        case (.l1Handler, false):
            self = try .l1Handler(StarknetProcessedL1HandlerTransactionReceipt(from: decoder))
        case (.deploy, false):
            self = try .deploy(StarknetProcessedDeployTransactionReceipt(from: decoder))
        case (.invoke, true):
            self = try .pendingInvoke(StarknetPendingInvokeTransactionReceipt(from: decoder))
        case (.declare, true):
            self = try .pendingDeclare(StarknetPendingDeclareTransactionReceipt(from: decoder))
        case (.deployAccount, true):
            self = try .pendingDeployAccount(StarknetPendingDeployAccountTransactionReceipt(from: decoder))
        case (.l1Handler, true):
            self = try .pendingL1Handler(StarknetPendingL1HandlerTransactionReceipt(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: Keys.type, in: container, debugDescription: "Invalid transaction receipt type (\(isPending ? "pending" : "") \(type))")
        }
    }
}
