import Foundation

public protocol StarknetAccountProtocol {
    /// Address of starknet account.
    var address: Felt { get }

    /// Sign list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    ///
    /// - Returns: Signed invoke v1 transaction
    func signV1(calls: [StarknetCall], params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV1

    /// Sign list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    ///
    /// - Returns: Signed invoke v3 transaction
    func signV3(calls: [StarknetCall], params: StarknetExecutionParamsV3, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV3

    /// Create and sign deploy account transaction v1
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    /// - Returns: Signed deploy account transaction v1
    func signDeployAccountV1(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV1

    /// Create and sign deploy account transaction v3
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    /// - Returns: Signed deploy account transaction v3
    func signDeployAccountV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetExecutionParamsV3, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV3

    /// Sign TypedData for off-chain usage with this account's privateKey.
    ///
    /// - Parameters:
    ///  - typedData: a TypedData object to sign
    /// - Returns: a signature for provided TypedData object.
    func sign(typedData: StarknetTypedData) throws -> StarknetSignature

    /// Verify a signature of TypedData on Starknet.
    ///
    /// - Parameters:
    ///  - signature: a signature of typedData
    ///  - typedData: a TypedData instance which signature will be verified
    /// - Returns: Boolean indicating whether the signature is valid.
    func verify(signature: StarknetSignature, for typedData: StarknetTypedData) async throws -> Bool

    /// Execute list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///  - params: additional params for a given transaction.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV1(calls: [StarknetCall], params: StarknetOptionalDeprecatedExecutionParams) async throws -> StarknetInvokeTransactionResponse

    /// Execute list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///  - params: additional params for a given transaction.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall], params: StarknetOptionalExecutionParamsV3) async throws -> StarknetInvokeTransactionResponse

    /// Execute list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV1(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse

    /// Execute list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse

    /// Estimate fee for a list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - nonce: nonce of the account.
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV1(calls: [StarknetCall], nonce: Felt, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - nonce: nonce of the account.
    ///  - simulationFlags: a set of simulation flags.

    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall], nonce: Felt, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate

    /// Estimate fee for a deploy account transaction
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    /// - Returns: struct containing fee estimate
    func estimateDeployAccountFeeV1(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt) async throws -> StarknetFeeEstimate

    func estimateDeployAccountFeeV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt) async throws -> StarknetFeeEstimate

    /// Get current nonce of the account
    ///
    /// - Returns: current nonce, as felt value.
    func getNonce() async throws -> Felt
}

public extension StarknetAccountProtocol {
    /// Sign list of calls for exectution as invoke transaction v1.
    /// Avoid using this method to sign calls for fee estimation.
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed invoke transaction v1
    func signV1(calls: [StarknetCall], params: StarknetDeprecatedExecutionParams) throws -> StarknetInvokeTransactionV1 {
        try signV1(calls: calls, params: params, forFeeEstimation: false)
    }

    /// Sign list of calls for execution as invoke transaction v3.
    /// Avoid using this method to sign calls for fee estimation.
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed invoke transaction v3
    func signV3(calls: [StarknetCall], params: StarknetExecutionParamsV3) throws -> StarknetInvokeTransactionV3 {
        try signV3(calls: calls, params: params, forFeeEstimation: false)
    }

    /// Create and sign deploy account transaction v1
    /// Avoid using this method to sign transaction for fee estimation.
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - maxFee: max acceptable fee for the transaction
    /// - Returns: Signed deploy account transaction v1
    func signDeployAccountV1(classHash: Felt, calldata: StarknetCalldata, salt: Felt, maxFee: Felt) throws -> StarknetDeployAccountTransactionV1 {
        try signDeployAccountV1(classHash: classHash, calldata: calldata, salt: salt, params: StarknetDeprecatedExecutionParams(nonce: .zero, maxFee: maxFee), forFeeEstimation: false)
    }

    /// Create and sign deploy account transaction v3
    /// Avoid using this method to sign transaction for fee estimation.
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - l1ResourceBounds: max acceptable l1 resource bounds
    /// - Returns: Signed deploy account transaction v3
    func signDeployAccountV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, l1ResourceBounds: StarknetResourceBounds) throws -> StarknetDeployAccountTransactionV3 {
        try signDeployAccountV3(classHash: classHash, calldata: calldata, salt: salt, params: StarknetExecutionParamsV3(nonce: .zero, l1ResourceBounds: l1ResourceBounds), forFeeEstimation: false)
    }

    /// Sign a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed invoke transaction v1
    func signV1(call: StarknetCall, params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool = false) throws -> StarknetInvokeTransactionV1 {
        try signV1(calls: [call], params: params, forFeeEstimation: forFeeEstimation)
    }

    /// Sign a call as invoke transaction v3
    /// - Parameters:
    ///  - call: a call to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed invoke transaction v3
    func signV3(call: StarknetCall, params: StarknetExecutionParamsV3, forFeeEstimation: Bool = false) throws -> StarknetInvokeTransactionV3 {
        try signV3(calls: [call], params: params, forFeeEstimation: forFeeEstimation)
    }

    /// Execute list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV1(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse {
        try await executeV1(calls: calls, params: StarknetOptionalDeprecatedExecutionParams())
    }

    /// Execute list of calls using invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse {
        try await executeV3(calls: calls, params: StarknetOptionalExecutionParamsV3())
    }

    /// Execute a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV1(call: StarknetCall, params: StarknetOptionalDeprecatedExecutionParams) async throws -> StarknetInvokeTransactionResponse {
        try await executeV1(calls: [call], params: params)
    }

    /// Execute a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(call: StarknetCall, params: StarknetOptionalExecutionParamsV3) async throws -> StarknetInvokeTransactionResponse {
        try await executeV3(calls: [call], params: params)
    }

    /// Execute a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV1(call: StarknetCall) async throws -> StarknetInvokeTransactionResponse {
        try await executeV1(calls: [call])
    }

    /// Execute a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(call: StarknetCall) async throws -> StarknetInvokeTransactionResponse {
        try await executeV3(calls: [call])
    }

    /// Estimate fee for a list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - nonce: nonce of the account.

    /// - Returns: struct containing fee estimate
    func estimateFeeV1(calls: [StarknetCall], nonce: Felt) async throws -> StarknetFeeEstimate {
        try await estimateFeeV1(calls: calls, nonce: nonce, simulationFlags: defaultSimulationFlagsForEstimateFee)
    }

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - nonce: nonce of the account.

    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall], nonce: Felt) async throws -> StarknetFeeEstimate {
        try await estimateFeeV3(calls: calls, nonce: nonce, simulationFlags: defaultSimulationFlagsForEstimateFee)
    }

    /// Estimate fee for a list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - simulationFlags: set of simulation flags for fee estimation.

    /// - Returns: struct containing fee estimate
    func estimateFeeV1(calls: [StarknetCall], simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        let nonce = try await getNonce()
        return try await estimateFeeV1(calls: calls, nonce: nonce, simulationFlags: simulationFlags)
    }

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - simulationFlags: set of simulation flags for fee estimation.

    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall], simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        let nonce = try await getNonce()
        return try await estimateFeeV3(calls: calls, nonce: nonce, simulationFlags: simulationFlags)
    }

    /// Estimate fee for a list of calls as invoke transaction v1
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    /// - Returns: struct containing fee estimate
    func estimateFeeV1(calls: [StarknetCall]) async throws -> StarknetFeeEstimate {
        let nonce = try await getNonce()
        return try await estimateFeeV1(calls: calls, nonce: nonce)
    }

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall]) async throws -> StarknetFeeEstimate {
        let nonce = try await getNonce()
        return try await estimateFeeV3(calls: calls, nonce: nonce)
    }

    /// Estimate fee for a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - nonce: a nonce to be used in a transaction.
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV1(call: StarknetCall, nonce: Felt, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        try await estimateFeeV1(calls: [call], nonce: nonce, simulationFlags: simulationFlags)
    }

    /// Estimate fee for a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - nonce: a nonce to be used in a transaction.
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(call: StarknetCall, nonce: Felt, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        try await estimateFeeV3(calls: [call], nonce: nonce, simulationFlags: simulationFlags)
    }

    /// Estimate fee for a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV1(call: StarknetCall, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        try await estimateFeeV1(calls: [call], simulationFlags: simulationFlags)
    }

    /// Estimate fee for a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - simulationFlags: a set of simulation flags.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(call: StarknetCall, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        try await estimateFeeV3(calls: [call], simulationFlags: simulationFlags)
    }

    /// Estimate fee for a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - nonce: a nonce to be used in a transaction.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV1(call: StarknetCall, nonce: Felt) async throws -> StarknetFeeEstimate {
        try await estimateFeeV1(calls: [call], nonce: nonce)
    }

    /// Estimate fee for a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - nonce: a nonce to be used in a transaction
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(call: StarknetCall, nonce: Felt) async throws -> StarknetFeeEstimate {
        try await estimateFeeV3(calls: [call], nonce: nonce)
    }

    /// Estimate fee for a call as invoke transaction v1
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV1(call: StarknetCall) async throws -> StarknetFeeEstimate {
        try await estimateFeeV1(calls: [call])
    }

    /// Estimate fee for a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(call: StarknetCall) async throws -> StarknetFeeEstimate {
        try await estimateFeeV3(calls: [call])
    }
}
