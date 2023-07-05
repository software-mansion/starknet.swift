import Foundation

public struct StarknetGetEventsFilter: Encodable {
    public let fromBlockId: StarknetBlockId?
    public let toBlockId: StarknetBlockId?
    public let address: Felt?
    public let keys: [[Felt]]?
    public let chunkSize: UInt64
    public let continuationToken: String?

    public init(fromBlockId: StarknetBlockId? = StarknetBlockId.tag(.pending), toBlockId: StarknetBlockId? = StarknetBlockId.tag(.pending), address: Felt? = nil, keys: [[Felt]]? = nil, chunkSize: UInt64 = 50, continuationToken: String? = nil) {
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

public struct StarknetEmittedEvent: Decodable, Equatable {
    public let address: Felt
    public let keys: [Felt]
    public let data: [Felt]
    public let blockHash: Felt
    public let blockNumber: UInt64
    public let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case blockHash = "block_hash"
        case blockNumber = "block_number"
        case transactionHash = "transaction_hash"
        case address = "from_address"
        case keys
        case data
    }
}

public struct StarknetEvent: Decodable, Equatable {
    public let address: Felt
    public let keys: [Felt]
    public let data: [Felt]

    enum CodingKeys: String, CodingKey {
        case address = "from_address"
        case keys
        case data
    }
}

public struct StarknetEventContent: Decodable, Equatable {
    public let keys: [Felt]
    public let data: [Felt]

    enum CodingKeys: String, CodingKey {
        case keys
        case data
    }
}
