import BigInt
import CryptoToolkit
import Foundation

public class Poseidon {
    private static let m = 3
    private static let r = 2

    /// Compute poseidon hash on single Felt.
    ///
    /// - Parameters:
    ///   - value: single value to hash.
    /// - Returns: Poseidon hash of the value as Felt.
    public class func poseidonHash(_ value: Felt) -> Felt {
        let state = [
            splitBigUInt(value.value),
            (0, 0, 0, 0),
            (1, 0, 0, 0),
        ]
        return Felt(clamping: combineToBigUInt(
            CryptoPoseidon.hades(state)[0]
        ))
    }

    /// Compute poseidon hash on two Felts.
    ///
    /// - Parameters:
    ///    - first: First value to hash.
    ///    - second: Second value to hash.
    /// - Returns: Poseidon hash of the two values as Felt.
    public class func poseidonHash(first: Felt, second: Felt) -> Felt {
        let state = [
            splitBigUInt(first.value),
            splitBigUInt(second.value),
            (2, 0, 0, 0),
        ]
        return Felt(clamping: combineToBigUInt(
            CryptoPoseidon.hades(state)[0]
        ))
    }

    /// Compute poseidon hash on many Felts.
    ///
    /// - Parameters:
    ///     - elements: array of Felt values to hash.
    /// - Returns: Poseidon hash of the values as Felt.
    public class func poseidonHash(_ values: [Felt]) -> Felt {
        if values.count == 1 {
            return poseidonHash(values[0])
        }
        if values.count == 2 {
            return poseidonHash(first: values[0], second: values[1])
        }
        var inputValues = values + [Felt.one]
        if inputValues.count % r == 1 {
            inputValues.append(Felt.zero)
        }
        var state: [(UInt64, UInt64, UInt64, UInt64)] = Array(repeating: (0, 0, 0, 0), count: m)

        for iter in stride(from: 0, to: inputValues.count, by: 2) {
            state = CryptoPoseidon.hades([
                splitBigUInt(combineToBigUInt(state[0]) + inputValues[iter].value),
                splitBigUInt(combineToBigUInt(state[1]) + inputValues[iter + 1].value),
                state[2],
            ])
        }

        return Felt(clamping: combineToBigUInt(state[0]))
    }

    /// Compute poseidon hash on variable number of Felts.
    ///
    /// - Parameters:
    ///    - values: any number of Felt values to hash.
    /// - Returns: Poseidon hash of the values as Felt.
    public class func poseidonHash(_ values: Felt...) -> Felt {
        poseidonHash(values)
    }

    /// Convert a BigUInt into a tuple of four 64-bit chunks.
    ///
    /// - Parameters:
    ///    - value: BigUInt to convert.
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
    /// - Parameters:
    ///    - values: Tuple of four 64-bit chunks.
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
