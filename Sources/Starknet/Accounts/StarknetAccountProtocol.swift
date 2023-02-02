import Foundation

public protocol StarknetAccountProtocol {
    /// Address of starknet account.
    var address: Felt { get }
    
    /// Sign list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed SequencerInvokeTransaction
    func sign(calls: [StarknetCall], params: StarknetExecutionParams) throws -> StarknetSequencerInvokeTransaction
    
    /// Create and sign deploy account transaction
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    ///  - maxFee: max acceptable fee for the transaction
    /// - Returns: Signed sequencer deploy account transaction
    func signDeployAccount(classHash: Felt, calldata: StarknetCalldata, salt: Felt, maxFee: Felt) throws -> StarknetSequencerDeployAccountTransaction
    
    /// Execute list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///  - maxFee: maximal fee that can be paid for the transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(calls: [StarknetCall], maxFee: Felt) async throws -> StarknetInvokeTransactionResponse
    
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
    func estimateFee(calls: [StarknetCall]) async throws -> StarknetEstimateFeeResponse
    
    /// Estimate fee for a deploy account transaction
    ///
    /// - Parameters:
    ///  - classHash: class hash of account to be deployed
    ///  - calldata: constructor calldata
    ///  - salt: contract salt
    /// - Returns: struct containing fee estimate
    func estimateDeployAccountFee(classHash: Felt, calldata: StarknetCalldata, salt: Felt) async throws -> StarknetEstimateFeeResponse
    
    /// Get current nonce of the account
    ///
    /// - Returns: current nonce, as felt value.
    func getNonce() async throws -> Felt
}

public extension StarknetAccountProtocol {
    
    /// Sign a call.
    ///
    /// - Parameters:
    ///  - call: a call to be signed.
    ///  - params: additional params for a given transaction
    ///
    /// - Returns: Signed SequencerInvokeTransaction
    func sign(call: StarknetCall, params: StarknetExecutionParams) throws -> StarknetSequencerInvokeTransaction {
        return try sign(calls: [call], params: params)
    }
    
    /// Execute a call
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///  - maxFee: maximal fee that can be paid for the transaction
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(call: StarknetCall, maxFee: Felt) async throws -> StarknetInvokeTransactionResponse {
        return try await execute(calls: [call], maxFee: maxFee)
    }
    
    /// Execute a call
    ///
    /// - Parameters:
    ///  - call: a call to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(call: StarknetCall) async throws -> StarknetInvokeTransactionResponse {
        return try await execute(calls: [call])
    }
    
    /// Estimate fee for a call
    ///
    /// - Parameters:
    ///  - call: a call for which the fee should be estimated.
    /// - Returns: struct containing fee estimate
    func estimateFee(call: StarknetCall) async throws -> StarknetEstimateFeeResponse {
        return try await estimateFee(calls: [call])
    }
}
