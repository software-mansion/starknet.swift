import Foundation

enum TransactionReceiptWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case blockHash = "block_hash"
        case blockNumber = "block_number"
    }

    case common(StarknetCommonTransactionReceipt)
    case pending(StarknetPendingTransactionReceipt)

    public var transactionReceipt: any StarknetTransactionReceipt {
        switch self {
        case let .common(tx):
            return tx
        case let .pending(tx):
            return tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let blockHash = try container.decodeIfPresent(Felt.self, forKey: Keys.blockHash)
        let blockNumber = try container.decodeIfPresent(Felt.self, forKey: Keys.blockHash)

        let isPending = blockHash == nil || blockNumber == nil

        if isPending {
            self = try .pending(StarknetPendingTransactionReceipt(from: decoder))
        } else {
            self = try .common(StarknetCommonTransactionReceipt(from: decoder))
        }
    }
}
