import Foundation

public class StarknetTransactionHashCalculator {
    private class func computeHashCommon(
        transactionType: StarknetTransactionType,
        version: Felt,
        contractAddress: Felt,
        entryPointSelector: Felt,
        calldata: StarknetCalldata,
        maxFee: Felt,
        chainId: StarknetChainId,
        nonce: Felt
    ) -> Felt {
        return StarknetCurve.pedersenOn(
            transactionType.encodedValue,
            version,
            contractAddress,
            entryPointSelector,
            StarknetCurve.pedersenOn(calldata),
            maxFee,
            chainId.feltValue,
            nonce
        )
    }
    
    public class func computeHash(of transaction: StarknetSequencerInvokeTransaction, chainId: StarknetChainId) -> Felt {
        return computeHashCommon(
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
    
    public class func computeHash(of transaction: StarknetSequencerDeployAccountTransaction, chainId: StarknetChainId) -> Felt {
        let contractAddress = StarknetContractAddressCalculator.calculateFrom(
            classHash: transaction.classHash,
            calldata: transaction.constructorCalldata,
            salt: transaction.contractAddressSalt
        )
        
        let calldata = [transaction.classHash, transaction.contractAddressSalt] + transaction.constructorCalldata
        
        return computeHashCommon(
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
}
