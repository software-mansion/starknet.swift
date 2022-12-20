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
    
    func estimateFee(calls: [StarknetCall]) async throws -> StarknetEstimateFeeResponse
    
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
    
    /// Execute list of calls
    ///
    /// - Parameters:
    ///  - calls: list of calls to be executed.
    ///
    /// - Returns: InvokeTransactionResponse, containing transaction hash of submitted transaction.
    func execute(call: StarknetCall) async throws -> StarknetInvokeTransactionResponse {
        return try await execute(calls: [call])
    }
    
    func estimateFee(call: StarknetCall) async throws -> StarknetEstimateFeeResponse {
        return try await estimateFee(calls: [call])
    }
}
