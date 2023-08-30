import Foundation

/// Transaction wrapper used for decoding polymorphic StarknetTransaction
enum TransactionWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case type
        case version
    }

    case invoke(StarknetInvokeTransactionV1)
    case invokeV0(StarknetInvokeTransactionV0)
    case deployAccount(StarknetDeployAccountTransaction)
    case deploy(StarknetDeployTransaction)
    case declareV0(StarknetDeclareTransactionV0)
    case declareV1(StarknetDeclareTransactionV1)
    case declareV2(StarknetDeclareTransactionV2)
    case l1Handler(StarknetL1HandlerTransaction)

    public var transaction: any StarknetTransaction {
        switch self {
        case let .invoke(tx):
            return tx
        case let .invokeV0(tx):
            return tx
        case let .deployAccount(tx):
            return tx
        case let .deploy(tx):
            return tx
        case let .declareV0(tx):
            return tx
        case let .declareV1(tx):
            return tx
        case let .declareV2(tx):
            return tx
        case let .l1Handler(tx):
            return tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)
        let version = try container.decode(Felt.self, forKey: Keys.version)

        switch (type, version) {
        case (.invoke, .one):
            self = try .invoke(StarknetInvokeTransactionV1(from: decoder))
        case (.invoke, .zero):
            self = try .invokeV0(StarknetInvokeTransactionV0(from: decoder))
        case (.declare, .zero):
            self = try .declareV0(StarknetDeclareTransactionV0(from: decoder))
        case (.declare, .one):
            self = try .declareV1(StarknetDeclareTransactionV1(from: decoder))
        case (.declare, 2):
            self = try .declareV2(StarknetDeclareTransactionV2(from: decoder))
        case (.deploy, .zero):
            self = try .deploy(StarknetDeployTransaction(from: decoder))
        case (.deployAccount, .one):
            self = try .deployAccount(StarknetDeployAccountTransaction(from: decoder))
        case (.l1Handler, .zero):
            self = try .l1Handler(StarknetL1HandlerTransaction(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: Keys.version, in: container, debugDescription: "Invalid transaction version (\(version) for transaction type (\(type))")
        }
    }
}
