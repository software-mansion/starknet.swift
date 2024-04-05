import Foundation

enum TransactionReceiptWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case type
    }

    case invoke(StarknetInvokeTransactionReceipt)
    case declare(StarknetDeclareTransactionReceipt)
    case deployAccount(StarknetDeployAccountTransactionReceipt)
    case l1Handler(StarknetL1HandlerTransactionReceipt)
    case deploy(StarknetDeployTransactionReceipt)

    public var transactionReceipt: any StarknetTransactionReceipt {
        switch self {
        case let .invoke(tx):
            tx
        case let .declare(tx):
            tx
        case let .deployAccount(tx):
            tx
        case let .l1Handler(tx):
            tx
        case let .deploy(tx):
            tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)

        switch type {
        case .invoke:
            self = try .invoke(StarknetInvokeTransactionReceipt(from: decoder))
        case .deployAccount:
            self = try .deployAccount(StarknetDeployAccountTransactionReceipt(from: decoder))
        case .declare:
            self = try .declare(StarknetDeclareTransactionReceipt(from: decoder))
        case .l1Handler:
            self = try .l1Handler(StarknetL1HandlerTransactionReceipt(from: decoder))
        case .deploy:
            self = try .deploy(StarknetDeployTransactionReceipt(from: decoder))
        }
    }
}
