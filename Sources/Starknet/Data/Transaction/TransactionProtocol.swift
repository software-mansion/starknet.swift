
public protocol StarknetSequencerTransaction: Codable {
    var type: StarknetTransactionType { get }
    var version: Felt { get }
}

public protocol StarknetTransaction: StarknetSequencerTransaction {
    var hash: Felt { get }

}

enum TransactionWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case type
        case version
    }

    case invoke(StarknetInvokeTransaction)
    case invokeV0(StarknetInvokeTransactionV0)
    case deployAccount(StarknetDeployAccountTransaction)
    case deploy(StarknetDeployTransaction)
    case declare(StarknetDeclareTransaction)
    case l1Handler(StarknetL1HandlerTransaction)

    public var transaction: StarknetTransaction {
        switch self {
        case .invoke(let tx):
            return tx
        case .invokeV0(let tx):
            return tx
        case .deployAccount(let tx):
            return tx
        case .deploy(let tx):
            return tx
        case .declare(let tx):
            return tx
        case .l1Handler(let tx):
            return tx
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)
        let version = try container.decode(Felt.self, forKey: Keys.version)

        switch (type, version) {
        case (.invoke, .one):
            self = .invoke(try StarknetInvokeTransaction(from: decoder))
        case (.invoke, .zero):
            self = .invokeV0(try StarknetInvokeTransactionV0(from: decoder))
        case (.declare, .one), (.declare, .zero):
            self = .declare(try StarknetDeclareTransaction(from: decoder))
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
