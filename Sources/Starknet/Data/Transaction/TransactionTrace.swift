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

public struct StarknetFunctionInvocation: Decodable, Equatable {
    public let contractAddress: Felt
    public let entrypoint: Felt
    public let calldata: StarknetCalldata
    public let callerAddress: Felt
    public let codeAddress: Felt
    public let entryPointType: StarknetEntryPointType
    public let callType: StarknetCallType
    public let result: [Felt]
    public let calls: [StarknetFunctionInvocation]
    public let events: [StarknetEventContent]
    public let messages: [MessageToL1]

    private enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case entrypoint
        case calldata
        case callerAddress = "caller_address"
        case codeAddress = "code_address"
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

public struct StarknetDeclareTransactionTrace: StarknetTransactionTrace {
    public let validateInvocation: StarknetFunctionInvocation?
    public let feeTransferInvocation: StarknetFunctionInvocation?

    private enum CodingKeys: String, CodingKey {
        case validateInvocation = "validate_invocation"
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
    case declare(StarknetDeclareTransactionTrace)
    case deployAccount(StarknetDeployAccountTransactionTrace)
    case l1Handler(StarknetL1HandlerTransactionTrace)

    public var transactionTrace: any StarknetTransactionTrace {
        switch self {
        case let .invoke(txTrace):
            return txTrace
        case let .declare(txTrace):
            return txTrace
        case let .deployAccount(txTrace):
            return txTrace
        case let .l1Handler(txTrace):
            return txTrace
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        if let validateInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .validateInvocation),
           let executeInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .executeInvocation),
           let feeTransferInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .feeTransferInvocation)
        {
            self = .invoke(StarknetInvokeTransactionTrace(
                validateInvocation: validateInvocation,
                executeInvocation: executeInvocation,
                feeTransferInvocation: feeTransferInvocation
            ))
        } else if let validateInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .validateInvocation),
                  let feeTransferInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .feeTransferInvocation)
        {
            self = .declare(StarknetDeclareTransactionTrace(
                validateInvocation: validateInvocation,
                feeTransferInvocation: feeTransferInvocation
            ))
        } else if let validateInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .validateInvocation),
                  let constructorInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .constructorInvocation),
                  let feeTransferInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .feeTransferInvocation)
        {
            self = .deployAccount(StarknetDeployAccountTransactionTrace(
                validateInvocation: validateInvocation,
                constructorInvocation: constructorInvocation,
                feeTransferInvocation: feeTransferInvocation
            ))
        } else if let functionInvocation = try container.decodeIfPresent(StarknetFunctionInvocation.self, forKey: .functionInvocation) {
            self = .l1Handler(StarknetL1HandlerTransactionTrace(
                functionInvocation: functionInvocation
            ))
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid transaction trace wrapper"
                )
            )
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

public enum StarknetSimulationFlag: String, Codable {
    case skipValidate = "SKIP_VALIDATE"
    case skipExecute = "SKIP_EXECUTE"
}
