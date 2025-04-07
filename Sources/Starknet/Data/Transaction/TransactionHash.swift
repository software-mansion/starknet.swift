import Foundation

public class StarknetTransactionHashCalculator {
    private static let l1GasPrefix = Felt.fromShortString("L1_GAS")!
    private static let l2GasPrefix = Felt.fromShortString("L2_GAS")!
    private static let l1DataGasPrefix = Felt.fromShortString("L1_DATA_GAS")!

    private class func computeCommonDeprecatedTransactionHash(
        transactionType: StarknetTransactionType,
        version: StarknetTransactionVersion,
        contractAddress: Felt,
        entryPointSelector: Felt,
        calldata: StarknetCalldata,
        maxFee: Felt,
        chainId: StarknetChainId,
        nonce: Felt
    ) -> Felt {
        StarknetCurve.pedersenOn(
            transactionType.encodedValue,
            version.value,
            contractAddress,
            entryPointSelector,
            StarknetCurve.pedersenOn(calldata),
            maxFee,
            chainId.value,
            nonce
        )
    }

    private class func prepareCommonTransactionV3Fields(of transaction: any StarknetTransactionV3, address: Felt, chainId: StarknetChainId) -> [Felt] {
        let transactionType = transaction.type
        let version = transaction.version
        let tip = transaction.tip
        let resourceBounds = transaction.resourceBounds
        let paymasterData = transaction.paymasterData
        let nonce = transaction.nonce
        let nonceDataAvailabilityMode = transaction.nonceDataAvailabilityMode
        let feeDataAvailabilityMode = transaction.feeDataAvailabilityMode

        return [
            transactionType.encodedValue,
            version.value,
            address,
            StarknetPoseidon.poseidonHash(
                [tip.value.toFelt()!]
                    + StarknetTransactionHashCalculator.resourceBoundsForFee(resourceBounds)
            ),
            StarknetPoseidon.poseidonHash(paymasterData),
            chainId.value,
            nonce,
            StarknetTransactionHashCalculator.dataAvailabilityModes(
                feeDataAvailabilityMode: feeDataAvailabilityMode,
                nonceDataAvailabilityMode: nonceDataAvailabilityMode
            ),
        ]
    }

    public class func computeHash(of transaction: StarknetInvokeTransactionV1, chainId: StarknetChainId) -> Felt {
        computeCommonDeprecatedTransactionHash(
            transactionType: transaction.type,
            version: transaction.version,
            contractAddress: transaction.senderAddress,
            entryPointSelector: .zero,
            calldata: transaction.calldata,
            maxFee: transaction.maxFee,
            chainId: chainId,
            nonce: transaction.nonce
        )
    }

    public class func computeHash(of transaction: StarknetInvokeTransactionV3, chainId: StarknetChainId) -> Felt {
        let commonFields = StarknetTransactionHashCalculator.prepareCommonTransactionV3Fields(
            of: transaction,
            address: transaction.senderAddress,
            chainId: chainId
        )
        return StarknetPoseidon.poseidonHash(
            commonFields + [
                StarknetPoseidon.poseidonHash(transaction.accountDeploymentData),
                StarknetPoseidon.poseidonHash(transaction.calldata),
            ]
        )
    }

    public class func computeHash(of transaction: StarknetDeployAccountTransactionV1, chainId: StarknetChainId) -> Felt {
        let contractAddress = StarknetContractAddressCalculator.calculateFrom(
            classHash: transaction.classHash,
            calldata: transaction.constructorCalldata,
            salt: transaction.contractAddressSalt
        )

        let calldata = [transaction.classHash, transaction.contractAddressSalt] + transaction.constructorCalldata

        return computeCommonDeprecatedTransactionHash(
            transactionType: transaction.type,
            version: transaction.version,
            contractAddress: contractAddress,
            entryPointSelector: .zero,
            calldata: calldata,
            maxFee: transaction.maxFee,
            chainId: chainId,
            nonce: .zero
        )
    }

    public class func computeHash(of transaction: StarknetDeployAccountTransactionV3, chainId: StarknetChainId) -> Felt {
        let contractAddress = StarknetContractAddressCalculator.calculateFrom(
            classHash: transaction.classHash,
            calldata: transaction.constructorCalldata,
            salt: transaction.contractAddressSalt
        )

        let commonFields = StarknetTransactionHashCalculator.prepareCommonTransactionV3Fields(
            of: transaction,
            address: contractAddress,
            chainId: chainId
        )
        return StarknetPoseidon.poseidonHash(
            commonFields + [
                StarknetPoseidon.poseidonHash(transaction.constructorCalldata),
                transaction.classHash,
                transaction.contractAddressSalt,
            ]
        )
    }

    private class func resourceBoundsForFee(_ resourceBounds: StarknetResourceBoundsMapping) -> [Felt] {
        let l1GasBound = l1GasPrefix.value << (64 + 128)
            + resourceBounds.l1Gas.maxAmount.value << 128
            + resourceBounds.l1Gas.maxPricePerUnit.value
        let l2GasBound = l2GasPrefix.value << (64 + 128)
            + resourceBounds.l2Gas.maxAmount.value << 128
            + resourceBounds.l2Gas.maxPricePerUnit.value
        let l1DataGasBound = l1DataGasPrefix.value << (64 + 128)
            + resourceBounds.l1DataGas.maxAmount.value << 128
            + resourceBounds.l1DataGas.maxPricePerUnit.value

        return [l1GasBound.toFelt()!, l2GasBound.toFelt()!, l1DataGasBound.toFelt()!]
    }

    private class func dataAvailabilityModes(
        feeDataAvailabilityMode: StarknetDAMode,
        nonceDataAvailabilityMode: StarknetDAMode
    ) -> Felt {
        (nonceDataAvailabilityMode.value << 32 + feeDataAvailabilityMode.value).toFelt()!
    }
}
