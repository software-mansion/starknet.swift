import Foundation

public protocol StarknetAccountProtocol {
    /// Address of starknet account.
    var address: Felt { get }
    /// Chain id of the Starknet provider.
    var chainId: StarknetChainId { get }

    /// Sign list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    ///
    /// - Returns: Signed invoke v3 transaction
    func signV3(calls: [StarknetCall], params: StarknetInvokeParamsV3, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV3

    /// Create and sign deploy account transaction v3
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    ///
    /// - Returns: Signed deploy account transaction v3
    func signDeployAccountV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetDeployAccountParamsV3, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV3

    /// Sign TypedData for off-chain usage with this account's privateKey.
    ///
    /// - Parameters:
    ///  - typedData: a TypedData object to sign
    ///
    /// - Returns: a signature for provided TypedData object.
    func sign(typedData: StarknetTypedData) throws -> StarknetSignature

    /// Verify a signature of TypedData on Starknet.
    ///
    /// - Parameters:
    ///  - signature: a signature of typedData
    ///  - typedData: a TypedData instance which signature will be verified
    ///
    /// - Returns: Boolean indicating whether the signature is valid.
    func verify(signature: StarknetSignature, for typedData: StarknetTypedData) async throws -> Bool

    /// Execute list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///  - params: additional params for a given transaction.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall], params: StarknetOptionalInvokeParamsV3) async throws -> StarknetRequest<StarknetInvokeTransactionResponse>

    /// Execute list of calls as invoke transaction v3 with automatically estimated fee that will be multiplied by the specified multipliers when resource bounds are calculated.
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///  - estimateAmountMultiplier: multiplier for the estimated amount.
    ///  - estimateUnitPriceMultiplier: multiplier for the estimated unit price.
    ///
    ///  - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall], estimateAmountMultiplier: Double, estimateUnitPriceMultiplier: Double) async throws -> StarknetRequest<StarknetInvokeTransactionResponse>

    /// Execute list of calls as invoke transaction v3 with automatically estimated fee
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall]) async throws -> StarknetRequest<StarknetInvokeTransactionResponse>

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - nonce: nonce of the account.
    ///  - skipValidate: Flag indicating whether validation of the transaction should be skipped.

    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall], nonce: Felt, skipValidate: Bool) async throws -> StarknetRequest<[StarknetFeeEstimate]>

    /// Estimate fee for a deploy account transaction v3
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - nonce: nonce of the account to be deployed
    ///  - skipValidate: flag indicating whether validation of the transaction should be skipped
    ///
    /// - Returns: struct containing fee estimate
    func estimateDeployAccountFeeV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt, skipValidate: Bool) async throws -> StarknetRequest<[StarknetFeeEstimate]>

    /// Get current nonce of the account
    ///
    /// - Returns: current nonce, as felt value.
    func getNonce() async throws -> StarknetRequest<Felt>
}

public extension StarknetAccountProtocol {
    /// Sign list of calls for execution as invoke transaction v3.
    /// Avoid using this method to sign calls for fee estimation.
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed invoke transaction v3
    func signV3(calls: [StarknetCall], params: StarknetInvokeParamsV3) throws -> StarknetInvokeTransactionV3 {
        try signV3(calls: calls, params: params, forFeeEstimation: false)
    }

    /// Create and sign deploy account transaction v3
    /// Avoid using this method to sign transaction for fee estimation.
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - resourceBounds: max acceptable l1 and l2 resource bounds
    ///
    /// - Returns: Signed deploy account transaction v3
    func signDeployAccountV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, resourceBounds: StarknetResourceBoundsMapping) throws -> StarknetDeployAccountTransactionV3 {
        try signDeployAccountV3(classHash: classHash, calldata: calldata, salt: salt, params: StarknetDeployAccountParamsV3(nonce: .zero, resourceBounds: resourceBounds), forFeeEstimation: false)
    }

    /// Sign a call as invoke transaction v3
    /// - Parameters:
    ///  - call: a call to be signed.
    ///  - params: additional params for a given transaction
    ///  - forFeeEstimation: Flag indicating whether the different version of transaction should be used; such transaction can only be used for fee estimation
    ///
    /// - Returns: Signed invoke transaction v3
    func signV3(call: StarknetCall, params: StarknetInvokeParamsV3, forFeeEstimation: Bool = false) throws -> StarknetInvokeTransactionV3 {
        try signV3(calls: [call], params: params, forFeeEstimation: forFeeEstimation)
    }

    /// Execute list of calls using invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(calls: [StarknetCall]) async throws -> StarknetRequest<StarknetInvokeTransactionResponse> {
        try await executeV3(calls: calls, params: StarknetOptionalInvokeParamsV3())
    }

    /// Execute a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(call: StarknetCall, params: StarknetOptionalInvokeParamsV3) async throws -> StarknetRequest<StarknetInvokeTransactionResponse> {
        try await executeV3(calls: [call], params: params)
    }

    /// Execute a call as invoke transaction v3 with automatically estimated fee that will be multiplied by the specified multipliers when resource bounds are calculated.
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///  - estimateAmountMultiplier: multiplier for the estimated amount.
    ///  - estimateUnitPriceMultiplier: multiplier for the estimated unit price.
    ///
    ///  - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(call: StarknetCall, estimateAmountMultiplier: Double, estimateUnitPriceMultiplier: Double) async throws -> StarknetRequest<StarknetInvokeTransactionResponse> {
        try await executeV3(calls: [call], estimateAmountMultiplier: estimateAmountMultiplier, estimateUnitPriceMultiplier: estimateUnitPriceMultiplier)
    }

    /// Execute a call as invoke transaction v3 with automatically estimated fee
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func executeV3(call: StarknetCall) async throws -> StarknetRequest<StarknetInvokeTransactionResponse> {
        try await executeV3(calls: [call])
    }

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - nonce: nonce of the account.

    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall], nonce: Felt) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        try await estimateFeeV3(calls: calls, nonce: nonce, skipValidate: false)
    }

    /// Estimate fee for a list of calls as invoke transaction v3
    ///
    /// - Parameters:
    ///  - calls: list of calls, for which the fee should be estimated.
    ///  - skipValidate: flag indicating whether validation of the transaction should be skipped.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(calls: [StarknetCall], provider: StarknetProviderProtocol, skipValidate: Bool = false) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        let nonce = try await provider.send(request: getNonce())
        return try await estimateFeeV3(calls: calls, nonce: nonce, skipValidate: skipValidate)
    }

    /// Estimate fee for a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - nonce: a nonce to be used in a transaction.
    ///  - skipValidate: flag indicating whether validation of the transaction should be skipped.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(call: StarknetCall, nonce: Felt, skipValidate: Bool = false) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        try await estimateFeeV3(calls: [call], nonce: nonce, skipValidate: skipValidate)
    }

    /// Estimate fee for a call as invoke transaction v3
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    ///  - skipValidate: flag indicating whether validation of the transaction should be skipped.
    ///
    /// - Returns: struct containing fee estimate
    func estimateFeeV3(call: StarknetCall, provider: StarknetProviderProtocol, skipValidate: Bool = false) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        try await estimateFeeV3(calls: [call], provider: provider, skipValidate: skipValidate)
    }

    /// Estimate fee for a deploy account transaction v3
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - nonce: nonce of the account to be deployed
    ///
    /// - Returns: struct containing fee estimate
    func estimateDeployAccountFeeV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt = .zero) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        try await estimateDeployAccountFeeV3(classHash: classHash, calldata: calldata, salt: salt, nonce: nonce, skipValidate: false)
    }
}
