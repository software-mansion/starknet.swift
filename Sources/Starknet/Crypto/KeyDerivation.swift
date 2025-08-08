import Foundation
import CryptoKit
import BigInt

// MARK: - Debug logging

enum GrindLog {
    private static let env = ProcessInfo.processInfo.environment
    static let enabled = env["GRIND_DEBUG"] == "1"
    static let full = env["GRIND_DEBUG_FULL"] == "1"

    static func log(_ msg: @autoclosure () -> String) {
        guard enabled else { return }
        fputs("[grindKey] \(msg())\n", stderr)
    }
}

private extension Data {
    // Hex string with optional masking for debug output.
    func hexPreview(maxChars: Int = 32) -> String {
        let hex = self.map { String(format: "%02x", $0) }.joined()
        if GrindLog.full || hex.count <= maxChars { return "0x" + hex }
        let half = maxChars / 2
        return "0x" + hex.prefix(half) + "…" + hex.suffix(half)
    }
}

private extension BigUInt {
    // Left-padded (if width provided) and masked for debug output.
    func hexPreview(width: Int? = 64, maxChars: Int = 32) -> String {
        let raw = String(self, radix: 16)
        let padded = width != nil ? raw.leftPadding(width: width!) : raw
        if GrindLog.full || padded.count <= maxChars { return "0x" + padded }
        let half = maxChars / 2
        return "0x" + padded.prefix(half) + "…" + padded.suffix(half)
    }
}

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
        GrindLog.log("start: seedLen=\(seed.count) seed=\(seed.hexPreview()) maxIters=\(maxIters)")

        let mask = BigUInt(1) << 256
        let limit = mask - (mask % STARK_EC_ORDER)

        GrindLog.log("curveOrder(n)=\(STARK_EC_ORDER.hexPreview())")
        GrindLog.log("limit=mask - (mask % n) = \(limit.hexPreview())")


        var i: UInt64 = 0
        while i <= UInt64(maxIters) {
            let iBytes = varIntBE(i)
            var input = Data(capacity: seed.count + iBytes.count)
            input.append(seed)
            input.append(iBytes)

            GrindLog.log("iter \(i): iBytes=\(iBytes.hexPreview()) inputLen=\(input.count)")


            let digest = SHA256.hash(data: input)
            let digestData = Data(digest)
            let x = BigUInt(digestData)
            // let x = BigUInt(Data(digest)) // SHA-256 is big-endian

            let cmp = x < limit
            GrindLog.log("iter \(i): sha256=\(digestData.hexPreview()) x=\(x.hexPreview()) x<limit=\(cmp)")

            if x < limit {
                let sk = x % STARK_EC_ORDER 
                GrindLog.log("iter \(i): ACCEPT -> sk = x % n = \(sk.hexPreview())")
                return x % STARK_EC_ORDER // in [0, n)
            }

            i &+= 1
        }
        GrindLog.log("FAILED: exceeded maxIters=\(maxIters)")
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
        let hex = "0x" + String(sk, radix: 16).leftPadding(width: 64)
        GrindLog.log("randomPrivateKeyHex -> \(GrindLog.full ? hex : (hex.prefix(10) + "…"))")
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

fileprivate extension String {
    func leftPadding(width: Int) -> String {
        if count >= width { return self }
        return String(repeating: "0", count: width - count) + self
    }
}
