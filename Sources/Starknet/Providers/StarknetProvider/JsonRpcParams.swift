import Foundation

typealias EmptySequence = [String]

struct EmptyParams: Encodable {}

struct CallParams: Encodable {
    let request: StarknetCall
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case request
        case blockId = "block_id"
    }
}

struct GetNonceParams: Encodable {
    let contractAddress: Felt
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case blockId = "block_id"
    }
}

struct AddInvokeTransactionParams: Encodable {
    let invokeTransaction: any StarknetExecutableInvokeTransaction

    func encode(to encoder: Encoder) throws {
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

struct EstimateFeeParams: Encodable {
    let request: [any StarknetExecutableTransaction]
    let simulationFlags: Set<StarknetSimulationFlagForEstimateFee>
    let blockId: StarknetBlockId

    func encode(to encoder: Encoder) throws {
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

struct EstimateMessageFeeParams: Encodable {
    let message: StarknetMessageFromL1
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case message
        case blockId = "block_id"
    }
}

struct AddDeployAccountTransactionParams: Encodable {
    let deployAccountTransaction: any StarknetExecutableDeployAccountTransaction

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(deployAccountTransaction, forKey: .deployAccountTransaction)
    }

    enum CodingKeys: String, CodingKey {
        case deployAccountTransaction = "deploy_account_transaction"
    }
}

struct GetClassHashAtParams: Encodable {
    let contractAddress: Felt
    let blockId: StarknetBlockId

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case blockId = "block_id"
    }
}

struct GetEventsPayload: Encodable {
    let filter: StarknetGetEventsFilter
}

struct GetTransactionByHashParams: Encodable {
    let hash: Felt

    enum CodingKeys: String, CodingKey {
        case hash = "transaction_hash"
    }
}

struct GetTransactionByBlockIdAndIndex: Encodable {
    let blockId: StarknetBlockId
    let index: UInt64

    enum CodingKeys: String, CodingKey {
        case blockId = "block_id"
        case index
    }
}

struct GetTransactionReceiptPayload: Encodable {
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

struct GetTransactionStatusPayload: Encodable {
    let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

struct SimulateTransactionsParams: Encodable {
    let transactions: [any StarknetExecutableTransaction]
    let blockId: StarknetBlockId
    let simulationFlags: Set<StarknetSimulationFlag>

    func encode(to encoder: Encoder) throws {
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

enum EncodableParams {
    case getNonceParams(GetNonceParams)
    case addInvokeTransactionParams(AddInvokeTransactionParams)
    case wrappedExecutableParams(WrappedExecutableTransaction)
    case emptySequenceParams(EmptySequence)
    case emptyParams(EmptyParams)
    case callParams(CallParams)
    case estimateFeeParams(EstimateFeeParams)
    case estimateMessageFeeParams(EstimateMessageFeeParams)
    case addDeployAccountTransactionParams(AddDeployAccountTransactionParams)
    case getClassHashAtParams(GetClassHashAtParams)
    case getEventsPayload(GetEventsPayload)
    case getTransactionByHashParams(GetTransactionByHashParams)
    case getTransactionByBlockIdAndIndex(GetTransactionByBlockIdAndIndex)
    case getTransactionReceiptPayload(GetTransactionReceiptPayload)
    case getTransactionStatusPayload(GetTransactionStatusPayload)
    case simulateTransactionsParams(SimulateTransactionsParams)
}

extension EncodableParams: Encodable {
    func encode(to encoder: Encoder) throws {
        switch self {
        case let .getNonceParams(params):
            try params.encode(to: encoder)
        case let .addInvokeTransactionParams(params):
            try params.encode(to: encoder)
        case let .wrappedExecutableParams(params):
            try params.encode(to: encoder)
        case let .emptySequenceParams(params):
            try params.encode(to: encoder)
        case let .emptyParams(params):
            try params.encode(to: encoder)
        case let .callParams(params):
            try params.encode(to: encoder)
        case let .estimateFeeParams(params):
            try params.encode(to: encoder)
        case let .estimateMessageFeeParams(params):
            try params.encode(to: encoder)
        case let .addDeployAccountTransactionParams(params):
            try params.encode(to: encoder)
        case let .getClassHashAtParams(params):
            try params.encode(to: encoder)
        case let .getEventsPayload(params):
            try params.encode(to: encoder)
        case let .getTransactionByHashParams(params):
            try params.encode(to: encoder)
        case let .getTransactionByBlockIdAndIndex(params):
            try params.encode(to: encoder)
        case let .getTransactionReceiptPayload(params):
            try params.encode(to: encoder)
        case let .getTransactionStatusPayload(params):
            try params.encode(to: encoder)
        case let .simulateTransactionsParams(params):
            try params.encode(to: encoder)
        }
    }
}
