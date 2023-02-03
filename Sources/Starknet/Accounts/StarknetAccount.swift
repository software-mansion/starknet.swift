import Foundation

public class StarknetAccount: StarknetAccountProtocol {
    public let address: Felt

    private let signer: StarknetSignerProtocol
    private let provider: StarknetProviderProtocol

    public init(address: Felt, signer: StarknetSignerProtocol, provider: StarknetProviderProtocol) {
        self.address = address
        self.signer = signer
        self.provider = provider
    }

    private func makeSequencerInvokeTransaction(calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetExecutionParams) -> StarknetSequencerInvokeTransaction {
        StarknetSequencerInvokeTransaction(senderAddress: address, calldata: calldata, signature: signature, maxFee: params.maxFee, nonce: params.nonce)
    }

    private func makeSequencerDeployAccountTransaction(classHash: Felt, salt: Felt, calldata: StarknetCalldata, maxFee: Felt, signature: StarknetSignature) -> StarknetSequencerDeployAccountTransaction {
        StarknetSequencerDeployAccountTransaction(
            signature: signature,
            maxFee: maxFee,
            nonce: .zero,
            contractAddressSalt: salt,
            constructorCalldata: calldata,
            classHash: classHash
        )
    }

    public func sign(calls: [StarknetCall], params: StarknetExecutionParams) throws -> StarknetSequencerInvokeTransaction {
        let calldata = callsToExecuteCalldata(calls: calls)

        let sequencerTransaction = makeSequencerInvokeTransaction(calldata: calldata, signature: [], params: params)

        let hash = StarknetTransactionHashCalculator.computeHash(of: sequencerTransaction, chainId: provider.starknetChainId)

        let transaction = StarknetInvokeTransaction(sequencerTransaction: sequencerTransaction, hash: hash)
        let signature = try signer.sign(transaction: transaction)

        return makeSequencerInvokeTransaction(calldata: calldata, signature: signature, params: params)
    }

    public func signDeployAccount(classHash: Felt, calldata: StarknetCalldata, salt: Felt, maxFee: Felt) throws -> StarknetSequencerDeployAccountTransaction {
        let sequencerTransaction = makeSequencerDeployAccountTransaction(classHash: classHash, salt: salt, calldata: calldata, maxFee: maxFee, signature: [])

        let hash = StarknetTransactionHashCalculator.computeHash(of: sequencerTransaction, chainId: provider.starknetChainId)
        let transaction = StarknetDeployAccountTransaction(sequencerTransaction: sequencerTransaction, hash: hash)

        let signature = try signer.sign(transaction: transaction)

        return makeSequencerDeployAccountTransaction(classHash: classHash, salt: salt, calldata: calldata, maxFee: maxFee, signature: signature)
    }

    public func execute(calls: [StarknetCall], maxFee: Felt) async throws -> StarknetInvokeTransactionResponse {
        let nonce = try await getNonce()
        let signParams = StarknetExecutionParams(nonce: nonce, maxFee: maxFee)
        let transaction = try sign(calls: calls, params: signParams)

        let result = try await provider.addInvokeTransaction(transaction)

        return result
    }

    public func execute(calls: [StarknetCall]) async throws -> StarknetInvokeTransactionResponse {
        let feeEstimate = try await estimateFee(calls: calls)
        let maxFee = estimatedFeeToMaxFee(feeEstimate.overallFee)

        return try await execute(calls: calls, maxFee: maxFee)
    }

    public func estimateFee(calls: [StarknetCall]) async throws -> StarknetEstimateFeeResponse {
        let nonce = try await getNonce()
        let signParams = StarknetExecutionParams(nonce: nonce, maxFee: .zero)
        let transaction = try sign(calls: calls, params: signParams)

        let result = try await provider.estimateFee(for: transaction)

        return result
    }

    public func estimateDeployAccountFee(classHash: Felt, calldata: StarknetCalldata, salt: Felt) async throws -> StarknetEstimateFeeResponse {
        let signedTransaction = try signDeployAccount(classHash: classHash, calldata: calldata, salt: salt, maxFee: .zero)

        let result = try await provider.estimateFee(for: signedTransaction)

        return result
    }

    public func getNonce() async throws -> Felt {
        let result = try await provider.getNonce(of: address)

        return result
    }
}
