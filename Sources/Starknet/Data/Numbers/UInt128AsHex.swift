import BigInt
import Foundation

public struct UInt128AsHex: NumAsHexProtocol {
    public let value: BigUInt

    public static let zero = UInt128AsHex(0)
    public static let one = UInt128AsHex(1)

    public static let min = UInt128AsHex.zero
    public static let max = UInt128AsHex(maxValue)!
    private static let maxValue = BigUInt(2).power(128) - 1

    public init?(_ exactly: some BinaryInteger) {
        let value = BigUInt(exactly: exactly)

        guard let value, value <= UInt128AsHex.maxValue else {
            return nil
        }

        self.value = value
    }

    public init(clamping: some BinaryInteger) {
        let value = BigUInt(clamping: clamping)

        self.value = value <= UInt128AsHex.maxValue ? value : UInt128AsHex.maxValue
    }

    public init?(fromHex hex: String) {
        guard hex.hasPrefix("0x") else { return nil }

        if let value = BigUInt(hex.dropFirst(2), radix: 16) {
            self.init(value)
        } else {
            return nil
        }
    }
}

extension UInt128AsHex: CustomDebugStringConvertible {
    public var debugDescription: String {
        "UInt128AsHex: \(self.value)"
    }
}
