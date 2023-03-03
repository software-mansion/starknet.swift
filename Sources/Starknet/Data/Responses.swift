import Foundation

public struct StarknetInvokeTransactionResponse: Decodable, Equatable {
    public let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

public struct StarknetEstimateFeeResponse: Decodable, Equatable {
    public let gasConsumed: Felt
    public let gasPrice: Felt
    public let overallFee: Felt

    enum CodingKeys: String, CodingKey {
        case gasConsumed = "gas_consumed"
        case gasPrice = "gas_price"
        case overallFee = "overall_fee"
    }
}

public struct StarknetDeployAccountResponse: Decodable, Equatable {
    public let transactionHash: Felt
    public let contractAddress: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case contractAddress = "contract_address"
    }
}

public struct StarknetBlockHashAndNumber: Decodable, Equatable {
    public let blockHash: Felt
    public let blockNumber: UInt64

    enum CodingKeys: String, CodingKey {
        case blockHash = "block_hash"
        case blockNumber = "block_number"
    }
}

public struct GetEventsResponse : Decodable, Equatable {
    public let continuationToken : String
    public let events : Array<EmittedEvent>
    
    enum CodingKeys: String, CodingKey {
        case continuationToken = "continuation_token"
        case events
    }
}

public struct EmittedEvent: Decodable, Equatable{
     let address: Felt
     let keys: Array<Felt>
     let data: Array<Felt>
     let blockHash: Felt
     let blockNumber: UInt64
     let transactionHash: Felt
     
     enum CodingKeys: String, CodingKey {
         case blockHash = "block_hash"
         case blockNumber = "block_number"
         case transactionHash = "transaction_hash"
         case address = "from_address"
         case keys
         case data
     }
 }
