import Foundation

/// Transaction wrapper used for decoding polymorphic StarknetTransaction
enum TransactionWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case type
        case version
    }

    case invokeV1(StarknetInvokeTransactionV1)
    case invokeV0(StarknetInvokeTransactionV0)
    case invokeV3(StarknetInvokeTransactionV3)
    case deployAccountV3(StarknetDeployAccountTransactionV3)
    case deployAccountV1(StarknetDeployAccountTransactionV1)
    case deploy(StarknetDeployTransaction)
    case declareV3(StarknetDeclareTransactionV3)
    case declareV2(StarknetDeclareTransactionV2)
    case declareV1(StarknetDeclareTransactionV1)
    case declareV0(StarknetDeclareTransactionV0)
    case l1Handler(StarknetL1HandlerTransaction)

    public var transaction: any StarknetTransaction {
        switch self {
        case let .invokeV3(tx):
            return tx
        case let .invokeV1(tx):
            return tx
        case let .invokeV0(tx):
            return tx
        case let .deployAccountV3(tx):
            return tx
        case let .deployAccountV1(tx):
            return tx
        case let .deploy(tx):
            return tx
        case let .declareV3(tx):
            return tx
        case let .declareV2(tx):
            return tx
        case let .declareV1(tx):
            return tx
        case let .declareV0(tx):
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
        case (.invoke, 3):
            self = try .invokeV3(StarknetInvokeTransactionV3(from: decoder))
        case (.invoke, .one):
            self = try .invokeV1(StarknetInvokeTransactionV1(from: decoder))
        case (.invoke, .zero):
            self = try .invokeV0(StarknetInvokeTransactionV0(from: decoder))
        case (.deployAccount, 3):
            self = try .deployAccountV3(StarknetDeployAccountTransactionV3(from: decoder))
        case (.deployAccount, .one):
            self = try .deployAccountV1(StarknetDeployAccountTransactionV1(from: decoder))
        case (.declare, 3):
            self = try .declareV3(StarknetDeclareTransactionV3(from: decoder))
        case (.declare, 2):
            self = try .declareV2(StarknetDeclareTransactionV2(from: decoder))
        case (.declare, .one):
            self = try .declareV1(StarknetDeclareTransactionV1(from: decoder))
        case (.declare, .zero):
            self = try .declareV0(StarknetDeclareTransactionV0(from: decoder))
        case (.deploy, .zero):
            self = try .deploy(StarknetDeployTransaction(from: decoder))
        case (.l1Handler, .zero):
            self = try .l1Handler(StarknetL1HandlerTransaction(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: Keys.version, in: container, debugDescription: "Invalid transaction version (\(version) for transaction type (\(type))")
        }
    }
}
