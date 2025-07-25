import BigInt
import Foundation

public class StarknetContractAddressCalculator {
    private static let contractAddressPrefix = Felt.fromShortString("STARKNET_CONTRACT_ADDRESS")!

    public class func calculateFrom(classHash: Felt, calldata: StarknetCalldata, salt: Felt, deployerAddress: Felt = .zero) -> Felt {
        StarknetCurve.pedersenOn(
            contractAddressPrefix,
            deployerAddress,
            salt,
            classHash,
            StarknetCurve.pedersenOn(calldata)
        )
    }

    public class func isChecksumAddressValid(address: String) -> Bool {
        calculateChecksumAddress(address: Felt(fromHex: address)!) == address
    }

    public class func calculateChecksumAddress(address: Felt) -> String {
        let hex = address.toHex().dropFirst(2)
        let stringAddress = String(String(hex.reversed()).padding(toLength: 64, withPad: "0", startingAt: 0).reversed())
        var chars = Array(stringAddress)
        let hashed = keccak(on: BigUInt(hex, radix: 16)!.serialize().byteArray)

        for i in 0 ... chars.count - 1 {
            let bit = BigUInt(2).power(256 - 4 * i - 1)
            if chars[i].isLetter, (hashed & bit) != 0 {
                chars[i] = (chars[i].uppercased()).first!
            }
        }

        return "0x\(String(chars))"
    }
}
