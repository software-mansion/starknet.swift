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
