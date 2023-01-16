import Foundation

public class StarknetContractAddressCalculator {
    private static let contractAddressPrefix = Felt.fromShortString("STARKNET_CONTRACT_ADDRESS")!
    
    public class func calculateFrom(classHash: Felt, calldata: StarknetCalldata, salt: Felt, deployerAddress: Felt = .zero) -> Felt {
        return StarknetCurve.pedersenOn(
            contractAddressPrefix,
            deployerAddress,
            salt,
            classHash,
            StarknetCurve.pedersenOn(calldata)
        )
    }
}
