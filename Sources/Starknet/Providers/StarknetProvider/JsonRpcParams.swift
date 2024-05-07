import Foundation

public typealias EmptySequence = [String]
public struct EmptyParams: Encodable {}

public struct CallParams: Encodable {
    let request: StarknetCall
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case request
        case blockId = "block_id"
    }
}

public struct GetNonceParams: Encodable {
    let contractAddress: Felt
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case blockId = "block_id"
    }
}

public struct AddInvokeTransactionParams: Encodable {
    let invokeTransaction: any StarknetExecutableInvokeTransaction

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(invokeTransaction, forKey: .invokeTransaction)
    }

    enum CodingKeys: String, CodingKey {
        case invokeTransaction = "invoke_transaction"
    }
}

// Workaround to allow encoding polymorphic array
struct WrappedExecutableTransaction: Encodable {
    let transaction: any StarknetExecutableTransaction

    func encode(to encoder: Encoder) throws {
        try transaction.encode(to: encoder)
    }
}

public struct EstimateFeeParams: Encodable {
    let request: [any StarknetExecutableTransaction]
    let simulationFlags: Set<StarknetSimulationFlagForEstimateFee>
    let blockId: StarknetBlockId

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let wrappedRequest = request.map { WrappedExecutableTransaction(transaction: $0) }

        try container.encode(wrappedRequest, forKey: .request)
        try container.encode(simulationFlags, forKey: .simulationFlags)
        try container.encode(blockId, forKey: .blockId)
    }

    enum CodingKeys: String, CodingKey {
        case request
        case simulationFlags = "simulation_flags"
        case blockId = "block_id"
    }
}

public struct EstimateMessageFeeParams: Encodable {
    let message: StarknetMessageFromL1
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case message
        case blockId = "block_id"
    }
}

public struct AddDeployAccountTransactionParams: Encodable {
    let deployAccountTransaction: any StarknetExecutableDeployAccountTransaction

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(deployAccountTransaction, forKey: .deployAccountTransaction)
    }

    enum CodingKeys: String, CodingKey {
        case deployAccountTransaction = "deploy_account_transaction"
    }
}

public struct GetClassHashAtParams: Encodable {
    let contractAddress: Felt
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case blockId = "block_id"
    }
}

public struct GetEventsPayload: Encodable {
    let filter: StarknetGetEventsFilter
}

public struct GetTransactionByHashParams: Encodable {
    let hash: Felt

    enum CodingKeys: String, CodingKey {
        case hash = "transaction_hash"
    }
}

public struct GetTransactionByBlockIdAndIndex: Encodable {
    let blockId: StarknetBlockId
    let index: UInt64

    enum CodingKeys: String, CodingKey {
        case blockId = "block_id"
        case index
    }
}

public struct GetTransactionReceiptPayload: Encodable {
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

public struct GetTransactionStatusPayload: Encodable {
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

public struct SimulateTransactionsParams: Encodable {
    let transactions: [any StarknetExecutableTransaction]
    let blockId: StarknetBlockId
    let simulationFlags: Set<StarknetSimulationFlag>

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let wrappedTransactions = transactions.map { WrappedExecutableTransaction(transaction: $0) }

        try container.encode(wrappedTransactions, forKey: .transactions)
        try container.encode(blockId, forKey: .blockId)
        try container.encode(simulationFlags, forKey: .simulationFlags)
    }

    enum CodingKeys: String, CodingKey {
        case transactions
        case blockId = "block_id"
        case simulationFlags = "simulation_flags"
    }
}
