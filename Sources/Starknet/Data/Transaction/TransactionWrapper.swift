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
    case declare(StarknetDeclareTransactionLegacy)
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
        case let .declare(tx):
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
            self = .invoke(try StarknetInvokeTransactionV1(from: decoder))
        case (.invoke, .zero):
            self = .invokeV0(try StarknetInvokeTransactionV0(from: decoder))
        case (.declare, .one), (.declare, .zero):
            self = .declare(try StarknetDeclareTransactionLegacy(from: decoder))
        case (.deploy, .zero):
            self = .deploy(try StarknetDeployTransaction(from: decoder))
        case (.deployAccount, .one):
            self = .deployAccount(try StarknetDeployAccountTransaction(from: decoder))
        case (.l1Handler, .zero):
            self = .l1Handler(try StarknetL1HandlerTransaction(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: Keys.version, in: container, debugDescription: "Invalid transaction version (\(version) for transaction type (\(type))")
        }
    }
}
