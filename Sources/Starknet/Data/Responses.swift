import Foundation

public struct StarknetInvokeTransactionResponse: Decodable, Equatable {
    public let transactionHash: Felt

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
    }
}

public struct StarknetFeeEstimate: Decodable, Equatable {
    public let l1GasConsumed: UInt64AsHex
    public let l1GasPrice: UInt128AsHex
    public let l2GasConsumed: UInt64AsHex
    public let l2GasPrice: UInt128AsHex
    public let l1DataGasConsumed: UInt64AsHex
    public let l1DataGasPrice: UInt128AsHex
    public let overallFee: UInt128AsHex
    public let feeUnit: StarknetPriceUnit

    enum CodingKeys: String, CodingKey {
        case l1GasConsumed = "l1_gas_consumed"
        case l1GasPrice = "l1_gas_price"
        case l2GasConsumed = "l2_gas_consumed"
        case l2GasPrice = "l2_gas_price"
        case l1DataGasConsumed = "l1_data_gas_consumed"
        case l1DataGasPrice = "l1_data_gas_price"
        case overallFee = "overall_fee"
        case feeUnit = "unit"
    }

    public init(l1GasConsumed: UInt64AsHex, l1GasPrice: UInt128AsHex, l2GasConsumed: UInt64AsHex, l2GasPrice: UInt128AsHex, l1DataGasConsumed: UInt64AsHex, l1DataGasPrice: UInt128AsHex, overallFee: UInt128AsHex, feeUnit: StarknetPriceUnit) {
        self.l1GasConsumed = l1GasConsumed
        self.l1GasPrice = l1GasPrice
        self.l2GasConsumed = l2GasConsumed
        self.l2GasPrice = l2GasPrice
        self.l1DataGasConsumed = l1DataGasConsumed
        self.l1DataGasPrice = l1DataGasPrice
        self.overallFee = overallFee
        self.feeUnit = feeUnit
    }

    public init?(l1GasConsumed: UInt64AsHex, l1GasPrice: UInt128AsHex, l2GasConsumed: UInt64AsHex, l2GasPrice: UInt128AsHex, l1DataGasConsumed: UInt64AsHex, l1DataGasPrice: UInt128AsHex, feeUnit: StarknetPriceUnit) {
        self.l1GasConsumed = l1GasConsumed
        self.l1GasPrice = l1GasPrice
        self.l2GasConsumed = l2GasConsumed
        self.l2GasPrice = l2GasPrice
        self.l1DataGasConsumed = l1DataGasConsumed
        self.l1DataGasPrice = l1DataGasPrice
        self.overallFee = UInt128AsHex(l1GasPrice.value * l1GasConsumed.value + l2GasPrice.value * l2GasConsumed.value + l1DataGasPrice.value * l1DataGasConsumed.value)!
        self.feeUnit = feeUnit
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

public struct StarknetGetStorageProofResponse: Decodable, Equatable {
    public let classesProof: StarknetNodeHashToNodeMapping
    public let contractsProof: StarknetContractsProof
    public let contractsStorageProofs: [StarknetNodeHashToNodeMapping]
    public let globalRoots: StarknetGlobalRoots

    enum CodingKeys: String, CodingKey {
        case classesProof = "classes_proof"
        case contractsProof = "contracts_proof"
        case contractsStorageProofs = "contracts_storage_proofs"
        case globalRoots = "global_roots"
    }
}

public struct StarknetGetTransactionStatusResponse: Decodable, Equatable {
    public let finalityStatus: StarknetTransactionStatus
    public let executionStatus: StarknetTransactionExecutionStatus?
    public let failureReason: String?

    enum CodingKeys: String, CodingKey {
        case finalityStatus = "finality_status"
        case executionStatus = "execution_status"
        case failureReason = "failure_reason"
    }
}
