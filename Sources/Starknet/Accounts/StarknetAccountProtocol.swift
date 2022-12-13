import Foundation

public protocol StarknetAccountProtocol {
    var address: Felt { get }
    
    func sign(calls: [StarknetCall], params: StarknetExecutionParams) -> StarknetSequencerInvokeTransaction
    
    func execute(calls: [StarknetCall], maxFee: Felt) async throws -> StarknetInvokeTransactionResponse
    
    func getNonce() async throws -> Felt
}

public extension StarknetAccountProtocol {
    func sign(call: StarknetCall, params: StarknetExecutionParams) -> StarknetSequencerInvokeTransaction {
        return sign(calls: [call], params: params)
    }
    
    func execute(call: StarknetCall, maxFee: Felt) async throws -> StarknetInvokeTransactionResponse {
        return try await execute(calls: [call], maxFee: maxFee)
    }
}
