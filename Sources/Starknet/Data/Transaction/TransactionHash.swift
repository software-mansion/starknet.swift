import Foundation

class TransactionHashCalculator {
    class func computeHash(of transaction: StarknetSequencerInvokeTransaction, chainId: StarknetChainId) -> Felt {
        return StarknetCurve.pedersenOn(
            transaction.type.encodedValue,
            transaction.version,
            transaction.senderAddress,
            Felt.zero,
            StarknetCurve.pedersenOn(transaction.calldata),
            transaction.maxFee,
            chainId.feltValue,
            transaction.nonce
        )
    }
}
