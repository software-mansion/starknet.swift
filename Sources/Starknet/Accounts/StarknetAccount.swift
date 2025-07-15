import BigInt
import Foundation

public enum StarknetAccountError: Error {
    case invalidResponse
}

public enum CairoVersion: String, Encodable {
    case zero
    case one
}

public class StarknetAccount: StarknetAccountProtocol {
    private let cairoVersion: CairoVersion
    public let address: Felt
    public let chainId: StarknetChainId

    private let signer: StarknetSignerProtocol
    private let provider: StarknetProviderProtocol

    public init(address: Felt, signer: StarknetSignerProtocol, provider: StarknetProviderProtocol, chainId: StarknetChainId, cairoVersion: CairoVersion) {
        self.address = address
        self.signer = signer
        self.provider = provider
        self.chainId = chainId
        self.cairoVersion = cairoVersion
    }

    private func makeInvokeTransactionV3(calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetInvokeParamsV3, forFeeEstimation: Bool = false) -> StarknetInvokeTransactionV3 {
        StarknetInvokeTransactionV3(senderAddress: address, calldata: calldata, signature: signature, resourceBounds: params.resourceBounds, nonce: params.nonce, forFeeEstimation: forFeeEstimation, tip: params.tip)
    }

    private func makeDeployAccountTransactionV3(classHash: Felt, salt: Felt, calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetDeployAccountParamsV3, forFeeEstimation: Bool) -> StarknetDeployAccountTransactionV3 {
        StarknetDeployAccountTransactionV3(signature: signature, resourceBounds: params.resourceBounds, nonce: params.nonce, contractAddressSalt: salt, constructorCalldata: calldata, classHash: classHash, forFeeEstimation: forFeeEstimation, tip: params.tip)
    }

    public func signV3(calls: [StarknetCall], params: StarknetInvokeParamsV3, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV3 {
        let calldata = starknetCallsToExecuteCalldata(calls: calls, cairoVersion: cairoVersion)

        let transaction = makeInvokeTransactionV3(calldata: calldata, signature: [], params: params, forFeeEstimation: forFeeEstimation)

        let hash = StarknetTransactionHashCalculator.computeHash(of: transaction, chainId: chainId)

        let signature = try signer.sign(transactionHash: hash)

        return makeInvokeTransactionV3(calldata: calldata, signature: signature, params: params, forFeeEstimation: forFeeEstimation)
    }

    public func signDeployAccountV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetDeployAccountParamsV3, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV3 {
        let transaction = makeDeployAccountTransactionV3(classHash: classHash, salt: salt, calldata: calldata, signature: [], params: params, forFeeEstimation: forFeeEstimation)

        let hash = StarknetTransactionHashCalculator.computeHash(of: transaction, chainId: chainId)

        let signature = try signer.sign(transactionHash: hash)

        return makeDeployAccountTransactionV3(classHash: classHash, salt: salt, calldata: calldata, signature: signature, params: params, forFeeEstimation: forFeeEstimation)
    }

    public func executeV3(calls: [StarknetCall], params: StarknetOptionalInvokeParamsV3) async throws -> StarknetRequest<StarknetInvokeTransactionResponse> {
        var nonce: Felt
        var resourceBounds: StarknetResourceBoundsMapping

        if let paramsNonce = params.nonce {
            nonce = paramsNonce
        } else {
            nonce = try await provider.send(request: getNonce())
        }
        print("NONCE", nonce)
        if let paramsResourceBounds = params.resourceBounds {
            resourceBounds = paramsResourceBounds
        } else {
            let feeEstimate = try await provider.send(request: estimateFeeV3(calls: calls, nonce: nonce))[0]
            resourceBounds = feeEstimate.toResourceBounds()
        }

        let params = StarknetInvokeParamsV3(nonce: nonce, resourceBounds: resourceBounds, tip: params.tip)
        let signedTransaction = try signV3(calls: calls, params: params, forFeeEstimation: false)

        return RequestBuilder.addInvokeTransaction(signedTransaction)
    }

    public func executeV3(calls: [StarknetCall], estimateAmountMultiplier: Double, estimateUnitPriceMultiplier: Double) async throws -> StarknetRequest<StarknetInvokeTransactionResponse> {
        let nonce = try await provider.send(request: getNonce())
        let feeEstimate = try await provider.send(request: estimateFeeV3(calls: calls, nonce: nonce))[0]
        let resourceBounds = feeEstimate.toResourceBounds(amountMultiplier: estimateAmountMultiplier, unitPriceMultiplier: estimateUnitPriceMultiplier)

        let params = StarknetInvokeParamsV3(nonce: nonce, resourceBounds: resourceBounds)
        let signedTransaction = try signV3(calls: calls, params: params, forFeeEstimation: false)

        return RequestBuilder.addInvokeTransaction(signedTransaction)
    }

    public func estimateFeeV3(calls: [StarknetCall], nonce: Felt, skipValidate: Bool) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        let params = StarknetInvokeParamsV3(nonce: nonce, resourceBounds: StarknetResourceBoundsMapping.zero)
        let signedTransaction = try signV3(calls: calls, params: params, forFeeEstimation: true)

        return RequestBuilder.estimateFee(for: signedTransaction, simulationFlags: skipValidate ? [.skipValidate] : [])
    }

    public func estimateDeployAccountFeeV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt, skipValidate: Bool) async throws -> StarknetRequest<[StarknetFeeEstimate]> {
        let params = StarknetDeployAccountParamsV3(nonce: nonce, resourceBounds: StarknetResourceBoundsMapping.zero)
        let signedTransaction = try signDeployAccountV3(classHash: classHash, calldata: calldata, salt: salt, params: params, forFeeEstimation: true)

        return RequestBuilder.estimateFee(for: signedTransaction, simulationFlags: skipValidate ? [.skipValidate] : [])
    }

    public func sign(typedData: StarknetTypedData) throws -> StarknetSignature {
        try signer.sign(typedData: typedData, accountAddress: address)
    }

    public func verify(signature: StarknetSignature, for typedData: StarknetTypedData) async throws -> Bool {
        let messageHash = try typedData.getMessageHash(accountAddress: address)

        let calldata = [messageHash, Felt(signature.count)!] + signature
        let call = StarknetCall(
            contractAddress: address,
            entrypoint: starknetSelector(from: "isValidSignature"),
            calldata: calldata
        )

        do {
            let result = try await provider.send(request: RequestBuilder.callContract(call))

            guard result.count == 1 else {
                throw StarknetAccountError.invalidResponse
            }

            return result[0] > 0
        } catch let StarknetProviderError.jsonRpcError(code, errorMessage, data) {
            // isValidSignature contract method throws an error, when the signature is incorrect,
            // so we catch it here.
            if errorMessage.contains("Signature"), errorMessage.contains("is invalid") {
                return false
            }
            if let unwrappedData = data, unwrappedData.contains("Signature"), unwrappedData.contains("is invalid") {
                return false
            }

            throw StarknetProviderError.jsonRpcError(code, errorMessage, data)
        }
        // And we want to rethrow all other errors.
    }

    public func getNonce() async throws -> StarknetRequest<Felt> {
        RequestBuilder.getNonce(of: address)
    }
}
