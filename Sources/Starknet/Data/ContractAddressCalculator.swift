import Foundation

class ContractAddressCalculator {
    private static let contractAddressPrefix = Felt.fromShortString("STARKNET_CONTRACT_ADDRESS")!
    
    class func calculateAddressFrom(classHash: Felt, calldata: StarknetCalldata, salt: Felt, deployerAddress: Felt = .zero) -> Felt {
        return StarknetCurve.pedersenOn(
            contractAddressPrefix,
            deployerAddress,
            salt,
            classHash,
            StarknetCurve.pedersenOn(calldata)
        )
    }
}
