import BigInt
import CryptoKit
import Foundation

public enum StarkKeygenError: Error {
    case rngFailure
    case grindExceeded
}

private let STARK_EC_ORDER = StarknetCurve.curveOrder

public enum StarkKeygen {
    /// Deterministically derives a valid Starknet private key.
    ///
    /// - Parameters:
    ///     - seed: bytes used as a seed to compute the key.
    ///     - maxIters: maximum number of iterations to avoid infinite loop or dos.
    /// - Returns: valid Starknet private key.
    public static func grindKey(seed: Data, maxIters: Int = 100_000) throws -> BigUInt {
        let mask = BigUInt(1) << 256
        let limit = mask - (mask % STARK_EC_ORDER)

        var i: UInt64 = 0
        while i <= UInt64(maxIters) {
            let iBytes = varIntBE(i)
            var input = Data(capacity: seed.count + iBytes.count)
            input.append(seed)
            input.append(iBytes)

            let digest = SHA256.hash(data: input)
            let x = BigUInt(Data(digest))

            if x < limit {
                return x % STARK_EC_ORDER // in [0, n)
            }

            i &+= 1
        }
        throw StarkKeygenError.grindExceeded
    }

    /// Generates a random Starknet private key.
    ///
    /// - Returns: a valid Starknet private key.
    public static func randomPrivateKeyHex() throws -> String {
        var seed = Data(count: 32)
        let status = seed.withUnsafeMutableBytes { ptr in
            SecRandomCopyBytes(kSecRandomDefault, ptr.count, ptr.baseAddress!)
        }
        guard status == errSecSuccess else { throw StarkKeygenError.rngFailure }

        let sk = try grindKey(seed: seed)
        return "0x" + String(sk, radix: 16).leftPadding(width: 64)
    }
}

/// Big-endian variable-length encoding for UInt64 (no leading zeros).
private func varIntBE(_ x: UInt64) -> Data {
    if x == 0 { return Data([0]) }
    var bytes: [UInt8] = []
    var v = x
    while v > 0 {
        bytes.append(UInt8(truncatingIfNeeded: v & 0xFF))
        v >>= 8
    }
    return Data(bytes.reversed())
}

private extension String {
    func leftPadding(width: Int) -> String {
        if count >= width { return self }
        return String(repeating: "0", count: width - count) + self
    }
}
