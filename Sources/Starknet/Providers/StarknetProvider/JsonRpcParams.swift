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
    let request: any StarknetSequencerTransaction
    let blockId: StarknetBlockId

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(request, forKey: .request)
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
