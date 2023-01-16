import Foundation

public class StarknetContractAddressCalculator {
    private static let contractAddressPrefix: Felt = "0x535441524b4e45545f434f4e54524143545f41444452455353"
    
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
