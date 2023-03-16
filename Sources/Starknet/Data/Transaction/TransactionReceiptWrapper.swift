import Foundation

enum TransactionReceiptWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case type
    }

    case invoke(StarknetCommonTransactionReceipt)
    case deployAccount(StarknetDeployTransactionReceipt)
    case deploy(StarknetDeployTransactionReceipt)
    case declare(StarknetCommonTransactionReceipt)
    case l1Handler(StarknetCommonTransactionReceipt)

    public var transactionReceipt: any StarknetTransactionReceipt {
        switch self {
        case let .invoke(tx):
            return tx
        case let .deployAccount(tx):
            return tx
        case let .deploy(tx):
            return tx
        case let .declare(tx):
            return tx
        case let .l1Handler(tx):
            return tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)

        switch type {
        case .invoke:
            self = .invoke(try StarknetCommonTransactionReceipt(from: decoder))
        case .declare:
            self = .declare(try StarknetCommonTransactionReceipt(from: decoder))
        case .deploy:
            self = .deploy(try StarknetDeployTransactionReceipt(from: decoder))
        case .deployAccount:
            self = .deployAccount(try StarknetDeployTransactionReceipt(from: decoder))
        case .l1Handler:
            self = .l1Handler(try StarknetCommonTransactionReceipt(from: decoder))
        }
    }
}
