import Foundation

public enum StarknetEntryPointType: String, Decodable {
    case external = "EXTERNAL"
    case l1Handler = "L1_HANDLER"
    case constructor = "CONSTRUCTOR"
}

public enum StarknetCallType: String, Decodable {
    case call = "CALL"
    case libraryCall = "LIBRARY_CALL"
}

public enum StarknetSimulationFlag: String, Codable {
    case skipValidate = "SKIP_VALIDATE"
    case skipExecute = "SKIP_EXECUTE"
}

public struct StarknetFunctionInvocation: Decodable, Equatable {
    public let contractAddress: Felt
    public let entrypoint: Felt
    public let calldata: StarknetCalldata
    public let callerAddress: Felt?
    public let classHash: Felt?
    public let entryPointType: StarknetEntryPointType?
    public let callType: StarknetCallType?
    public let result: [Felt]?
    public let calls: [StarknetFunctionInvocation]?
    public let events: [StarknetEventContent]?
    public let messages: [MessageToL1]?

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
    }
}

public protocol StarknetTransactionTrace: Decodable, Equatable {}

public struct StarknetInvokeTransactionTrace: StarknetTransactionTrace {
    public let validateInvocation: StarknetFunctionInvocation?
    public let executeInvocation: StarknetFunctionInvocation?
    public let feeTransferInvocation: StarknetFunctionInvocation?

    private enum CodingKeys: String, CodingKey {
        case validateInvocation = "validate_invocation"
        case executeInvocation = "execute_invocation"
        case feeTransferInvocation = "fee_transfer_invocation"
    }
}

public struct StarknetDeployAccountTransactionTrace: StarknetTransactionTrace {
    public let validateInvocation: StarknetFunctionInvocation?
    public let constructorInvocation: StarknetFunctionInvocation?
    public let feeTransferInvocation: StarknetFunctionInvocation?

    private enum CodingKeys: String, CodingKey {
        case validateInvocation = "validate_invocation"
        case constructorInvocation = "constructor_invocation"
        case feeTransferInvocation = "fee_transfer_invocation"
    }
}

public struct StarknetL1HandlerTransactionTrace: StarknetTransactionTrace {
    public let functionInvocation: StarknetFunctionInvocation?

    private enum CodingKeys: String, CodingKey {
        case functionInvocation = "function_invocation"
    }
}

enum StarknetTransactionTraceWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case validateInvocation = "validate_invocation"
        case executeInvocation = "execute_invocation"
        case feeTransferInvocation = "fee_transfer_invocation"
        case constructorInvocation = "constructor_invocation"
        case functionInvocation = "function_invocation"
    }

    case invoke(StarknetInvokeTransactionTrace)
    case deployAccount(StarknetDeployAccountTransactionTrace)
    case l1Handler(StarknetL1HandlerTransactionTrace)

    public var transactionTrace: any StarknetTransactionTrace {
        switch self {
        case let .invoke(txTrace):
            return txTrace
        case let .deployAccount(txTrace):
            return txTrace
        case let .l1Handler(txTrace):
            return txTrace
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        // Invocations can be null, so `if let = try?` syntax won't work here.
        do {
            let validateInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .validateInvocation)
            let executeInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .executeInvocation)
            let feeTransferInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .feeTransferInvocation)

            self = .invoke(StarknetInvokeTransactionTrace(
                validateInvocation: validateInvocation,
                executeInvocation: executeInvocation,
                feeTransferInvocation: feeTransferInvocation
            ))
            return
        } catch {}

        do {
            let validateInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .validateInvocation)
            let constructorInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .constructorInvocation)
            let feeTransferInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .feeTransferInvocation)

            self = .deployAccount(StarknetDeployAccountTransactionTrace(
                validateInvocation: validateInvocation,
                constructorInvocation: constructorInvocation,
                feeTransferInvocation: feeTransferInvocation
            ))
            return
        } catch {}

        do {
            let functionInvocation = try container.decode(StarknetFunctionInvocation?.self, forKey: .functionInvocation)

            self = .l1Handler(StarknetL1HandlerTransactionTrace(
                functionInvocation: functionInvocation
            ))
            return
        } catch {}

        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid transaction trace"
            ))
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
