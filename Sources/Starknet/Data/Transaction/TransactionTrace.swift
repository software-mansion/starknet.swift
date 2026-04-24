import Foundation

public enum StarknetEntryPointType: String, Decodable {
    case external = "EXTERNAL"
    case l1Handler = "L1_HANDLER"
    case constructor = "CONSTRUCTOR"
}

public enum StarknetCallType: String, Decodable {
    case call = "CALL"
    case libraryCall = "LIBRARY_CALL"
    case delegate = "DELEGATE"
}

public enum StarknetSimulationFlag: String, Codable {
    case skipValidate = "SKIP_VALIDATE"
    case skipFeeCharge = "SKIP_FEE_CHARGE"
    case returnInitialReads = "RETURN_INITIAL_READS"
}

public enum StarknetSimulationFlagForEstimateFee: String, Codable {
    case skipValidate = "SKIP_VALIDATE"
}

public enum StarknetTraceFlag: String, Codable {
    case returnInitialReads = "RETURN_INITIAL_READS"
}

public enum StarknetTxnResponseFlag: String, Codable {
    case includeProofFacts = "INCLUDE_PROOF_FACTS"
}

public enum StarknetStorageResponseFlag: String, Codable {
    case includeLastUpdateBlock = "INCLUDE_LAST_UPDATE_BLOCK"
}

public struct StarknetFunctionInvocation: Decodable, Equatable {
    public let contractAddress: Felt
    public let entrypoint: Felt
    public let calldata: StarknetCalldata
    public let callerAddress: Felt
    public let classHash: Felt
    public let entryPointType: StarknetEntryPointType
    public let callType: StarknetCallType
    public let result: [Felt]
    public let calls: [StarknetFunctionInvocation]
    public let events: [StarknetOrderedEvent]
    public let messages: [StarknetOrderedMessageToL1]
    public let executionResources: StarknetInnerCallExecutionResources
    public let isReverted: Bool

    private enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case entrypoint = "entry_point_selector"
        case calldata
        case callerAddress = "caller_address"
        case classHash = "class_hash"
        case entryPointType = "entry_point_type"
        case callType = "call_type"
        case result
        case calls
        case events
        case messages
        case executionResources = "execution_resources"
        case isReverted = "is_reverted"
    }
}

public struct StarknetRevertedFunctionInvocation: Decodable, Equatable {
    public let revertReason: String

    private enum CodingKeys: String, CodingKey {
        case revertReason = "revert_reason"
    }
}

public protocol StarknetTransactionTrace: Decodable, Equatable {
    var stateDiff: StarknetStateDiff? { get }
    var type: StarknetTransactionType { get }
}

public protocol StarknetInvokeTransactionTraceProtocol: StarknetTransactionTrace {
    var validateInvocation: StarknetFunctionInvocation? { get }
    var feeTransferInvocation: StarknetFunctionInvocation? { get }
    var stateDiff: StarknetStateDiff? { get }
    var executionResources: StarknetExecutionResources { get }
    var type: StarknetTransactionType { get }
}

public struct StarknetInvokeTransactionTrace: StarknetInvokeTransactionTraceProtocol {
    public let validateInvocation: StarknetFunctionInvocation?
    public let executeInvocation: StarknetFunctionInvocation
    public let feeTransferInvocation: StarknetFunctionInvocation?
    public let stateDiff: StarknetStateDiff?
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionType = .invoke

    private enum CodingKeys: String, CodingKey {
        case validateInvocation = "validate_invocation"
        case executeInvocation = "execute_invocation"
        case feeTransferInvocation = "fee_transfer_invocation"
        case stateDiff = "state_diff"
        case executionResources = "execution_resources"
    }
}

public struct StarknetRevertedInvokeTransactionTrace: StarknetInvokeTransactionTraceProtocol {
    public let validateInvocation: StarknetFunctionInvocation?
    public let executeInvocation: StarknetRevertedFunctionInvocation
    public let feeTransferInvocation: StarknetFunctionInvocation?
    public let stateDiff: StarknetStateDiff?
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionType = .invoke

    private enum CodingKeys: String, CodingKey {
        case validateInvocation = "validate_invocation"
        case executeInvocation = "execute_invocation"
        case feeTransferInvocation = "fee_transfer_invocation"
        case stateDiff = "state_diff"
        case executionResources = "execution_resources"
    }
}

public struct StarknetDeployAccountTransactionTrace: StarknetTransactionTrace {
    public let validateInvocation: StarknetFunctionInvocation?
    public let constructorInvocation: StarknetFunctionInvocation
    public let feeTransferInvocation: StarknetFunctionInvocation?
    public let stateDiff: StarknetStateDiff?
    public let executionResources: StarknetExecutionResources
    public let type: StarknetTransactionType = .deployAccount

    private enum CodingKeys: String, CodingKey {
        case validateInvocation = "validate_invocation"
        case constructorInvocation = "constructor_invocation"
        case feeTransferInvocation = "fee_transfer_invocation"
        case stateDiff = "state_diff"
        case executionResources = "execution_resources"
    }
}

public struct StarknetL1HandlerTransactionTrace: StarknetTransactionTrace {
    public let functionInvocation: StarknetFunctionInvocation
    public let stateDiff: StarknetStateDiff?
    public let executionResources: StarknetExecutionResources?
    public let type: StarknetTransactionType = .l1Handler

    private enum CodingKeys: String, CodingKey {
        case functionInvocation = "function_invocation"
        case stateDiff = "state_diff"
        case executionResources = "execution_resources"
    }
}

enum StarknetTransactionTraceWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case executeInvocation = "execute_invocation"
        case type
    }

    case invoke(StarknetInvokeTransactionTrace)
    case revertedInvoke(StarknetRevertedInvokeTransactionTrace)
    case deployAccount(StarknetDeployAccountTransactionTrace)
    case l1Handler(StarknetL1HandlerTransactionTrace)

    var transactionTrace: any StarknetTransactionTrace {
        switch self {
        case let .invoke(txTrace):
            txTrace
        case let .revertedInvoke(txTrace):
            txTrace
        case let .deployAccount(txTrace):
            txTrace
        case let .l1Handler(txTrace):
            txTrace
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let type = try container.decode(StarknetTransactionType.self, forKey: Keys.type)
        let revertedFunctionInvocation = try? container.decodeIfPresent(StarknetRevertedFunctionInvocation.self, forKey: Keys.executeInvocation)
        let isReverted = revertedFunctionInvocation != nil

        switch (type, isReverted) {
        case (.invoke, false):
            self = try .invoke(StarknetInvokeTransactionTrace(from: decoder))
        case (.invoke, true):
            self = try .revertedInvoke(StarknetRevertedInvokeTransactionTrace(from: decoder))
        case (.deployAccount, _):
            self = try .deployAccount(StarknetDeployAccountTransactionTrace(from: decoder))
        case (.l1Handler, _):
            self = try .l1Handler(StarknetL1HandlerTransactionTrace(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: Keys.type, in: container, debugDescription: "Invalid transaction type (\(type))")
        }
    }
}

public struct StarknetSimulatedTransaction: Decodable {
    public let transactionTrace: any StarknetTransactionTrace
    public let feeEstimation: StarknetFeeEstimate

    enum CodingKeys: String, CodingKey {
        case transactionTrace = "transaction_trace"
        case feeEstimation = "fee_estimation"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        transactionTrace = try container.decode(StarknetTransactionTraceWrapper.self, forKey: .transactionTrace).transactionTrace
        feeEstimation = try container.decode(StarknetFeeEstimate.self, forKey: .feeEstimation)
    }
}

public struct StarknetStorageEntry: Decodable, Equatable {
    public let contractAddress: Felt
    public let key: Felt
    public let value: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case key
        case value
    }
}

public struct StarknetNonceEntry: Decodable, Equatable {
    public let contractAddress: Felt
    public let nonce: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case nonce
    }
}

public struct StarknetClassHashEntry: Decodable, Equatable {
    public let contractAddress: Felt
    public let classHash: Felt

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case classHash = "class_hash"
    }
}

public struct StarknetDeclaredContractEntry: Decodable, Equatable {
    public let classHash: Felt
    public let isDeclared: Bool

    enum CodingKeys: String, CodingKey {
        case classHash = "class_hash"
        case isDeclared = "is_declared"
    }
}

public struct StarknetInitialReads: Decodable, Equatable {
    public let storage: [StarknetStorageEntry]
    public let nonces: [StarknetNonceEntry]
    public let classHashes: [StarknetClassHashEntry]
    public let declaredContracts: [StarknetDeclaredContractEntry]

    enum CodingKeys: String, CodingKey {
        case storage
        case nonces
        case classHashes = "class_hashes"
        case declaredContracts = "declared_contracts"
    }
}

public enum StarknetSimulateTransactionsResult: Decodable {
    case transactions([StarknetSimulatedTransaction])
    case withInitialReads(simulatedTransactions: [StarknetSimulatedTransaction], initialReads: StarknetInitialReads)

    enum CodingKeys: String, CodingKey {
        case simulatedTransactions = "simulated_transactions"
        case initialReads = "initial_reads"
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           container.contains(.simulatedTransactions)
        {
            let txs = try container.decode([StarknetSimulatedTransaction].self, forKey: .simulatedTransactions)
            let reads = try container.decode(StarknetInitialReads.self, forKey: .initialReads)
            self = .withInitialReads(simulatedTransactions: txs, initialReads: reads)
        } else {
            let txs = try [StarknetSimulatedTransaction](from: decoder)
            self = .transactions(txs)
        }
    }
}

public struct StarknetBlockTransactionTrace: Decodable {
    public let transactionHash: Felt
    public let traceRoot: any StarknetTransactionTrace

    enum CodingKeys: String, CodingKey {
        case transactionHash = "transaction_hash"
        case traceRoot = "trace_root"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        transactionHash = try container.decode(Felt.self, forKey: .transactionHash)
        traceRoot = try container.decode(StarknetTransactionTraceWrapper.self, forKey: .traceRoot).transactionTrace
    }
}

public enum StarknetTraceBlockTransactionsResult: Decodable {
    case traces([StarknetBlockTransactionTrace])
    case withInitialReads(traces: [StarknetBlockTransactionTrace], initialReads: StarknetInitialReads)

    enum CodingKeys: String, CodingKey {
        case traces
        case initialReads = "initial_reads"
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self),
           container.contains(.traces)
        {
            let traces = try container.decode([StarknetBlockTransactionTrace].self, forKey: .traces)
            let reads = try container.decode(StarknetInitialReads.self, forKey: .initialReads)
            self = .withInitialReads(traces: traces, initialReads: reads)
        } else {
            let traces = try [StarknetBlockTransactionTrace](from: decoder)
            self = .traces(traces)
        }
    }
}
