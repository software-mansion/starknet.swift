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
    let request: StarknetSequencerTransaction
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

public struct Filter: Encodable {
    let fromBlockId: StarknetBlockId?
    let toBlockId: StarknetBlockId?
    let address: Felt?
    let keys: [Felt]?
    let chunkSize: UInt64
    let continuationToken: String?

    init(fromBlockId: StarknetBlockId? = StarknetBlockId.tag(.pending), toBlockId: StarknetBlockId? = StarknetBlockId.tag(.pending), address: Felt? = nil, keys: [Felt]? = nil, chunkSize: UInt64 = 50, continuationToken: String? = nil) {
        self.fromBlockId = fromBlockId
        self.toBlockId = toBlockId
        self.address = address
        self.keys = keys
        self.chunkSize = chunkSize
        self.continuationToken = continuationToken
    }

    enum CodingKeys: String, CodingKey {
        case fromBlockId = "from_block"
        case toBlockId = "to_block"
        case chunkSize = "chunk_size"
        case continuationToken = "continuation_token"
        case keys
        case address
    }
}

struct GetEventsPayload: Encodable {
    let filter: Filter
}

struct EmptyParams: Encodable {}
