import Foundation

public struct StarknetInvokeTransactionResponse: Decodable, Equatable {
    public let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

public struct StarknetFeeEstimate: Decodable, Equatable {
    public let gasConsumed: Felt
    public let gasPrice: Felt
    public let dataGasConsumed: Felt
    public let dataGasPrice: Felt
    public let overallFee: Felt
    public let feeUnit: StarknetPriceUnit

    enum CodingKeys: String, CodingKey {
        case gasConsumed = "gas_consumed"
        case gasPrice = "gas_price"
        case dataGasConsumed = "data_gas_consumed"
        case dataGasPrice = "data_gas_price"
        case overallFee = "overall_fee"
        case feeUnit = "unit"
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

public struct StarknetGetEventsResponse: Decodable, Equatable {
    public let continuationToken: String?
    public let events: [StarknetEmittedEvent]

    enum CodingKeys: String, CodingKey {
        case continuationToken = "continuation_token"
        case events
    }
}

public struct StarknetGetTransactionStatusResponse: Decodable, Equatable {
    public let finalityStatus: StarknetTransactionStatus
    public let executionStatus: StarknetTransactionExecutionStatus?

    enum CodingKeys: String, CodingKey {
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
    }
}
