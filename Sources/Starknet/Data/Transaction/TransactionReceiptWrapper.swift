import Foundation

enum TransactionReceiptWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case blockHash = "block_hash"
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

        // Pending transaction won't have the block_hash value
        do {
            let _ = try container.decode(Felt.self, forKey: Keys.blockHash)
            self = try .common(StarknetCommonTransactionReceipt(from: decoder))
        } catch {
            self = try .pending(StarknetPendingTransactionReceipt(from: decoder))
        }
    }
}
