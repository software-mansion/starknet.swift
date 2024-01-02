import BigInt
import CryptoToolkit
import Foundation

public class Poseidon {
    /// Compute poseidon hash on input values.
    ///
    /// - Returns: Poseidon hash of the two values as Felt.
    public class func poseidonHash(x: Felt, y: Felt) -> Felt {
        let state = [
            splitBigUInt(x.value),
            splitBigUInt(y.value),
            (2, 0, 0, 0),
        ]
        return Felt(clamping: combineToBigUInt(
            CryptoPoseidon.hades(state)[0]
        ))
    }

    /// Convert a BigUInt into a tuple of 64-bit chunks.
    ///
    /// - Returns: Tuple of 64-bit chunks.
    private static func splitBigUInt(_ value: BigUInt) -> (UInt64, UInt64, UInt64, UInt64) {
        var result: [UInt64] = [0, 0, 0, 0]

        // if the input is zero, return the array of zeros
        if value != BigUInt(0) {
            // mask has all bits set to 1 except the least significant one
            let mask = BigUInt(2).power(64) - 1

            // loop through the 64-bit chunks of the BigUInt, shift them and store in the result array
            for i in 0 ..< 4 {
                result[i] = UInt64(value >> (i * 64) & mask)
            }
        }

        return (result[0], result[1], result[2], result[3])
    }

    /// Combine a tuple of 64-bit chunks into a single BigUInt.
    ///
    /// - Returns: BigUInt.
    private static func combineToBigUInt(_ values: (UInt64, UInt64, UInt64, UInt64)) -> BigUInt {
        let arr: [UInt64] = [values.0, values.1, values.2, values.3]
        let powersOfTwo = [
            BigUInt(2).power(0),
            BigUInt(2).power(64),
            BigUInt(2).power(128),
            BigUInt(2).power(192),
        ]

        // w * 2**0 + x * 2**64 + y * 2**128 + z * 2**192
        var result = BigUInt(0)
        for (b, p) in zip(arr, powersOfTwo) {
            result += BigUInt(b) * p
        }
        return result
    }
}
