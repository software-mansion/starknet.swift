import Foundation

class StarknetAccount: StarknetAccountProtocol {
    public let address: Felt
    
    private let signer: StarknetSignerProtocol
    private let provider: StarknetProviderProtocol
    
    public init(address: Felt, signer: StarknetSignerProtocol, provider: StarknetProviderProtocol) {
        self.address = address
        self.signer = signer
        self.provider = provider
    }
    
    private func makeSequencerInvokeTransaction(calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetExecutionParams) -> StarknetSequencerInvokeTransaction {
        return StarknetSequencerInvokeTransaction(senderAddress: address, calldata: calldata, signature: signature, maxFee: params.maxFee, nonce: params.nonce)
    }
    
    func sign(calls: [StarknetCall], params: StarknetExecutionParams) -> StarknetSequencerInvokeTransaction {
        let calldata = callsToExecuteCalldata(calls: calls)
        
        let sequencerTransaction = makeSequencerInvokeTransaction(calldata: calldata, signature: [], params: params)
        
        let hash = TransactionHashCalculator.computeHash(of: sequencerTransaction, chainId: provider.starknetChainId)! // TODO: Shouldn't force unwrap here
        
        let transaction = StarknetInvokeTransaction(sequencerTransaction: sequencerTransaction, hash: hash)
        let signature = signer.sign(transaction: transaction)! // TODO: Shouldn't force unwrap here
        
        return makeSequencerInvokeTransaction(calldata: calldata, signature: signature, params: params)
    }
    
    func execute(calls: [StarknetCall], maxFee: Felt) async throws -> StarknetInvokeTransactionResponse {
        let nonce = try await getNonce()
        let signParams = StarknetExecutionParams(nonce: nonce, maxFee: maxFee)
        let transaction = sign(calls: calls, params: signParams)
        
        let result = try await provider.addInvokeTransaction(transaction)
        
        return result
    }
    
    func getNonce() async throws -> Felt {
        let result = try await provider.getNonce(of: address)
        
        return result
    }
}