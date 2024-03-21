import Foundation

enum TransactionReceiptWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case type
    }

    case invokeBlockInfo(StarknetInvokeTransactionReceiptWithBlockInfo)
    case declareBlockInfo(StarknetDeclareTransactionReceiptWithBlockInfo)
    case deployAccountBlockInfo(StarknetDeployAccountTransactionReceiptWithBlockInfo)
    case l1HandlerBlockInfo(StarknetL1HandlerTransactionReceiptWithBlockInfo)
    case deployBlockInfo(StarknetDeployTransactionReceiptWithBlockInfo)
    case invoke(StarknetInvokeTransactionReceipt)
    case declare(StarknetDeclareTransactionReceipt)
    case deployAccount(StarknetDeployAccountTransactionReceipt)
    case l1Handler(StarknetL1HandlerTransactionReceipt)
    case deploy(StarknetDeployTransactionReceipt)

    public var transactionReceipt: any StarknetTransactionReceipt {
        switch self {
        case let .invokeBlockInfo(tx):
            return tx
        case let .declareBlockInfo(tx):
            return tx
        case let .deployAccountBlockInfo(tx):
            return tx
        case let .l1HandlerBlockInfo(tx):
            return tx
        case let .deployBlockInfo(tx):
            return tx
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
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)
        let blockHash = try container.decodeIfPresent(Felt.self, forKey: Keys.blockHash)
        let blockNumber = try container.decodeIfPresent(Felt.self, forKey: Keys.blockHash)

        let hasBlockInfo = blockHash != nil && blockNumber != nil

        switch (type, hasBlockInfo) {
        case (.invoke, true):
            self = try .invokeBlockInfo(StarknetInvokeTransactionReceiptWithBlockInfo(from: decoder))
        case (.declare, true):
            self = try .declareBlockInfo(StarknetDeclareTransactionReceiptWithBlockInfo(from: decoder))
        case (.deployAccount, true):
            self = try .deployAccountBlockInfo(StarknetDeployAccountTransactionReceiptWithBlockInfo(from: decoder))
        case (.l1Handler, true):
            self = try .l1HandlerBlockInfo(StarknetL1HandlerTransactionReceiptWithBlockInfo(from: decoder))
        case (.deploy, true):
            self = try .deployBlockInfo(StarknetDeployTransactionReceiptWithBlockInfo(from: decoder))
        case (.invoke, false):
            self = try .invoke(StarknetInvokeTransactionReceipt(from: decoder))
        case (.declare, false):
            self = try .declare(StarknetDeclareTransactionReceipt(from: decoder))
        case (.deployAccount, false):
            self = try .deployAccount(StarknetDeployAccountTransactionReceipt(from: decoder))
        case (.l1Handler, false):
            self = try .l1Handler(StarknetL1HandlerTransactionReceipt(from: decoder))
        case (.deploy, false):
            self = try .deploy(StarknetDeployTransactionReceipt(from: decoder))
        }
    }
}
