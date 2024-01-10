import Foundation

public protocol StarknetAccountProtocol {
    /// Address of starknet account.
    var address: Felt { get }

    /// Sign list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed.
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    ///
    /// - Returns: Signed SequencerInvokeTransaction
    func sign(calls: [StarknetCall], params: StarknetExecutionParams, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV1

    /// Create and sign deploy account transaction
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    /// - Returns: Signed sequencer deploy account transaction
    func signDeployAccount(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetExecutionParams, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV1

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

    /// Execute list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(calls: [StarknetCall], params: StarknetOptionalExecutionParams) async throws -> StarknetInvokeTransactionResponse

    /// Execute list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse

    /// Estimate fee for a list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    /// - Returns: struct containing fee estimate
    func estimateFee(calls: [StarknetCall], nonce: Felt) async throws -> StarknetFeeEstimate

    /// Estimate fee for a deploy account transaction
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    /// - Returns: struct containing fee estimate
    func estimateDeployAccountFee(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt) async throws -> StarknetFeeEstimate

    /// Get current nonce of the account
    ///
    /// - Returns: current nonce, as felt value.
    func getNonce() async throws -> Felt
}

public extension StarknetAccountProtocol {
    /// Sign list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed SequencerInvokeTransaction
    func sign(calls: [StarknetCall], params: StarknetExecutionParams) throws -> StarknetInvokeTransactionV1 {
        try sign(calls: calls, params: params, forFeeEstimation: false)
    }

    /// Create and sign deploy account transaction
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - maxFee: max acceptable fee for the transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    /// - Returns: Signed sequencer deploy account transaction
    func signDeployAccount(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetExecutionParams) throws -> StarknetDeployAccountTransactionV1 {
        try signDeployAccount(classHash: classHash, calldata: calldata, salt: salt, params: params, forFeeEstimation: false)
    }

    /// Sign a call.
    ///
    /// - Parameters:
    ///  - call: a call to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed SequencerInvokeTransaction
    func sign(call: StarknetCall, params: StarknetExecutionParams, forFeeEstimation: Bool = false) throws -> StarknetInvokeTransactionV1 {
        try sign(calls: [call], params: params, forFeeEstimation: forFeeEstimation)
    }

    /// Execute list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse {
        try await execute(calls: calls, params: StarknetOptionalExecutionParams())
    }

    /// Execute a call
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(call: StarknetCall, params: StarknetOptionalExecutionParams) async throws -> StarknetInvokeTransactionResponse {
        try await execute(calls: [call], params: params)
    }

    /// Execute a call
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(call: StarknetCall) async throws -> StarknetInvokeTransactionResponse {
        try await execute(calls: [call])
    }

    /// Estimate fee for a list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    /// - Returns: struct containing fee estimate
    func estimateFee(calls: [StarknetCall]) async throws -> StarknetFeeEstimate {
        let nonce = try await getNonce()
        return try await estimateFee(calls: calls, nonce: nonce)
    }

    /// Estimate fee for a call
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - nonce: a nonce to be used in a transaction
    /// - Returns: struct containing fee estimate
    func estimateFee(call: StarknetCall, nonce: Felt) async throws -> StarknetFeeEstimate {
        try await estimateFee(calls: [call], nonce: nonce)
    }

    /// Estimate fee for a call
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    /// - Returns: struct containing fee estimate
    func estimateFee(call: StarknetCall) async throws -> StarknetFeeEstimate {
        try await estimateFee(calls: [call])
    }
}
