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
}

public enum StarknetSimulationFlagForEstimateFee: String, Codable {
    case skipValidate = "SKIP_VALIDATE"
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
