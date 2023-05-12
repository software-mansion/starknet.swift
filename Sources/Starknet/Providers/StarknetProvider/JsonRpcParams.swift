import Foundation

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
    let invokeTransaction: StarknetSequencerInvokeTransaction

    enum CodingKeys: String, CodingKey {
        case invokeTransaction = "invoke_transaction"
    }
}

struct EstimateFeeParams: Encodable {
    let request: [any StarknetSequencerTransaction]
    let blockId: StarknetBlockId

    // Walkaround to allow encoding polymorphic array
    struct WrappedSequencerTransaction: Encodable {
        let transaction: any StarknetSequencerTransaction

        func encode(to encoder: Encoder) throws {
            try transaction.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let wrappedRequest = request.map { WrappedSequencerTransaction(transaction: $0) }

        try container.encode(wrappedRequest, forKey: .request)
        try container.encode(blockId, forKey: .blockId)
    }

    enum CodingKeys: String, CodingKey {
        case request
        case blockId = "block_id"
    }
}

struct AddDeployAccountTransactionParams: Encodable {
    let deployAccountTransaction: StarknetSequencerDeployAccountTransaction

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

struct EmptyParams: Encodable {}
