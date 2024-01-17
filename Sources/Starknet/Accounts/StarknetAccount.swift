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

    private let signer: StarknetSignerProtocol
    private let provider: StarknetProviderProtocol

    public init(address: Felt, signer: StarknetSignerProtocol, provider: StarknetProviderProtocol, cairoVersion: CairoVersion) {
        self.address = address
        self.signer = signer
        self.provider = provider
        self.cairoVersion = cairoVersion
    }

    private func makeInvokeTransactionV1(calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool = false) -> StarknetInvokeTransactionV1 {
        StarknetInvokeTransactionV1(senderAddress: address, calldata: calldata, signature: signature, maxFee: params.maxFee, nonce: params.nonce, forFeeEstimation: forFeeEstimation)
    }

    private func makeInvokeTransactionV3(calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetExecutionParamsV3, forFeeEstimation: Bool = false) -> StarknetInvokeTransactionV3 {
        StarknetInvokeTransactionV3(senderAddress: address, calldata: calldata, signature: signature, l1ResourceBounds: params.resourceBounds.l1Gas, nonce: params.nonce, forFeeEstimation: forFeeEstimation)
    }

    private func makeDeployAccountTransactionV1(classHash: Felt, salt: Felt, calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool) -> StarknetDeployAccountTransactionV1 {
        StarknetDeployAccountTransactionV1(
            signature: signature,
            maxFee: params.maxFee,
            nonce: params.nonce,
            contractAddressSalt: salt,
            constructorCalldata: calldata,
            classHash: classHash,
            forFeeEstimation: forFeeEstimation
        )
    }

    private func makeDeployAccountTransactionV3(classHash: Felt, salt: Felt, calldata: StarknetCalldata, signature: StarknetSignature, params: StarknetExecutionParamsV3, forFeeEstimation: Bool) -> StarknetDeployAccountTransactionV3 {
        StarknetDeployAccountTransactionV3(
            signature: signature,
            l1ResourceBounds: params.resourceBounds.l1Gas,
            nonce: params.nonce,
            contractAddressSalt: salt,
            constructorCalldata: calldata,
            classHash: classHash,
            forFeeEstimation: forFeeEstimation
        )
    }

    public func signV1(calls: [StarknetCall], params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV1 {
        let calldata = starknetCallsToExecuteCalldata(calls: calls, cairoVersion: cairoVersion)

        let transaction = makeInvokeTransactionV1(calldata: calldata, signature: [], params: params, forFeeEstimation: forFeeEstimation)

        let hash = StarknetTransactionHashCalculator.computeHash(of: transaction, chainId: provider.starknetChainId)

        let signature = try signer.sign(transactionHash: hash)

        return makeInvokeTransactionV1(calldata: calldata, signature: signature, params: params, forFeeEstimation: forFeeEstimation)
    }

    public func signV3(calls: [StarknetCall], params: StarknetExecutionParamsV3, forFeeEstimation: Bool) throws -> StarknetInvokeTransactionV3 {
        let calldata = starknetCallsToExecuteCalldata(calls: calls, cairoVersion: cairoVersion)

        let transaction = makeInvokeTransactionV3(calldata: calldata, signature: [], params: params, forFeeEstimation: forFeeEstimation)

        let hash = StarknetTransactionHashCalculator.computeHash(of: transaction, chainId: provider.starknetChainId)

        let signature = try signer.sign(transactionHash: hash)

        return makeInvokeTransactionV3(calldata: calldata, signature: signature, params: params, forFeeEstimation: forFeeEstimation)
    }

    public func signDeployAccountV1(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetDeprecatedExecutionParams, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV1 {
        let transaction = makeDeployAccountTransactionV1(classHash: classHash, salt: salt, calldata: calldata, signature: [], params: params, forFeeEstimation: forFeeEstimation)

        let hash = StarknetTransactionHashCalculator.computeHash(of: transaction, chainId: provider.starknetChainId)

        let signature = try signer.sign(transactionHash: hash)

        return makeDeployAccountTransactionV1(classHash: classHash, salt: salt, calldata: calldata, signature: signature, params: params, forFeeEstimation: forFeeEstimation)
    }

    public func signDeployAccountV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, params: StarknetExecutionParamsV3, forFeeEstimation: Bool) throws -> StarknetDeployAccountTransactionV3 {
        let transaction = makeDeployAccountTransactionV3(classHash: classHash, salt: salt, calldata: calldata, signature: [], params: params, forFeeEstimation: forFeeEstimation)

        let hash = StarknetTransactionHashCalculator.computeHash(of: transaction, chainId: provider.starknetChainId)

        let signature = try signer.sign(transactionHash: hash)

        return makeDeployAccountTransactionV3(classHash: classHash, salt: salt, calldata: calldata, signature: signature, params: params, forFeeEstimation: forFeeEstimation)
    }

    public func executeV1(calls: [StarknetCall], params: StarknetOptionalDeprecatedExecutionParams) async throws -> StarknetInvokeTransactionResponse {
        var nonce: Felt
        var maxFee: Felt

        if let paramsNonce = params.nonce {
            nonce = paramsNonce
        } else {
            nonce = try await getNonce()
        }

        if let paramsMaxFee = params.maxFee {
            maxFee = paramsMaxFee
        } else {
            let feeEstimate = try await estimateFeeV1(calls: calls, nonce: nonce)
            maxFee = estimatedFeeToMaxFee(feeEstimate.overallFee)
        }

        let params = StarknetDeprecatedExecutionParams(nonce: nonce, maxFee: maxFee)
        let signedTransaction = try signV1(calls: calls, params: params, forFeeEstimation: false)

        return try await provider.addInvokeTransaction(signedTransaction)
    }

    public func executeV3(calls: [StarknetCall], params: StarknetOptionalExecutionParamsV3) async throws -> StarknetInvokeTransactionResponse {
        var nonce: Felt
        var resourceBounds: StarknetResourceBoundsMapping

        if let paramsNonce = params.nonce {
            nonce = paramsNonce
        } else {
            nonce = try await getNonce()
        }

        if let paramsResourceBounds = params.resourceBounds {
            resourceBounds = paramsResourceBounds
        } else {
            let feeEstimate = try await estimateFeeV3(calls: calls, nonce: nonce)
            resourceBounds = feeEstimate.toResourceBounds()
        }

        let params = StarknetExecutionParamsV3(nonce: nonce, l1ResourceBounds: resourceBounds.l1Gas)
        let signedTransaction = try signV3(calls: calls, params: params, forFeeEstimation: false)

        return try await provider.addInvokeTransaction(signedTransaction)
    }

    public func estimateFeeV1(calls: [StarknetCall], nonce: Felt, simulationFlags: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        let params = StarknetDeprecatedExecutionParams(nonce: nonce, maxFee: .zero)
        let signedTransaction = try signV1(calls: calls, params: params, forFeeEstimation: true)

        return try await provider.estimateFee(for: signedTransaction, simulationFlags: simulationFlags)
    }

    public func estimateFeeV3(calls: [StarknetCall], nonce: Felt, simulationFlags _: Set<StarknetSimulationFlagForEstimateFee>) async throws -> StarknetFeeEstimate {
        let params = StarknetExecutionParamsV3(nonce: nonce, l1ResourceBounds: .zero)
        let signedTransaction = try signV3(calls: calls, params: params, forFeeEstimation: true)

        return try await provider.estimateFee(for: signedTransaction)
    }

    public func estimateDeployAccountFeeV1(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt) async throws -> StarknetFeeEstimate {
        let params = StarknetDeprecatedExecutionParams(nonce: nonce, maxFee: 0)
        let signedTransaction = try signDeployAccountV1(classHash: classHash, calldata: calldata, salt: salt, params: params, forFeeEstimation: true)

        return try await provider.estimateFee(for: signedTransaction)
    }

    public func estimateDeployAccountFeeV3(classHash: Felt, calldata: StarknetCalldata, salt: Felt, nonce: Felt) async throws -> StarknetFeeEstimate {
        let params = StarknetExecutionParamsV3(nonce: nonce, l1ResourceBounds: .zero)
        let signedTransaction = try signDeployAccountV3(classHash: classHash, calldata: calldata, salt: salt, params: params, forFeeEstimation: true)

        return try await provider.estimateFee(for: signedTransaction)
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
            let result = try await provider.callContract(call)

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

    public func getNonce() async throws -> Felt {
        let result = try await provider.getNonce(of: address)

        return result
    }
}
