import Foundation

/// Transaction wrapper used for decoding polymorphic StarknetTransaction
public enum TransactionWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case type
        case version
    }

    case invokeV3(StarknetInvokeTransactionV3)
    case invokeV1(StarknetInvokeTransactionV1)
    case invokeV0(StarknetInvokeTransactionV0)
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
            tx
        case let .invokeV1(tx):
            tx
        case let .invokeV0(tx):
            tx
        case let .deployAccountV3(tx):
            tx
        case let .deployAccountV1(tx):
            tx
        case let .deploy(tx):
            tx
        case let .declareV3(tx):
            tx
        case let .declareV2(tx):
            tx
        case let .declareV1(tx):
            tx
        case let .declareV0(tx):
            tx
        case let .l1Handler(tx):
            tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)
        let version = try container.decode(StarknetTransactionVersion.self, forKey: Keys.version)

        switch (type, version) {
        case (.invoke, .v3):
            self = try .invokeV3(StarknetInvokeTransactionV3(from: decoder))
        case (.invoke, .v1):
            self = try .invokeV1(StarknetInvokeTransactionV1(from: decoder))
        case (.invoke, .v0):
            self = try .invokeV0(StarknetInvokeTransactionV0(from: decoder))
        case (.deployAccount, .v3):
            self = try .deployAccountV3(StarknetDeployAccountTransactionV3(from: decoder))
        case (.deployAccount, .v1):
            self = try .deployAccountV1(StarknetDeployAccountTransactionV1(from: decoder))
        case (.declare, .v3):
            self = try .declareV3(StarknetDeclareTransactionV3(from: decoder))
        case (.declare, .v2):
            self = try .declareV2(StarknetDeclareTransactionV2(from: decoder))
        case (.declare, .v1):
            self = try .declareV1(StarknetDeclareTransactionV1(from: decoder))
        case (.declare, .v0):
            self = try .declareV0(StarknetDeclareTransactionV0(from: decoder))
        case (.deploy, .v0):
            self = try .deploy(StarknetDeployTransaction(from: decoder))
        case (.l1Handler, .v0):
            self = try .l1Handler(StarknetL1HandlerTransaction(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: Keys.version, in: container, debugDescription: "Invalid transaction version (\(version) for transaction type (\(type))")
        }
    }
}
