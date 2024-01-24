import BigInt
import Foundation

public extension BigUInt {
    func toFelt() -> Felt? {
        Felt(self)
    }

    func toFeltClamped() -> Felt {
        self > Felt.max.value ? Felt.max : Felt(self)!
    }

    func toUInt64AsHex() -> UInt64AsHex? {
        UInt64AsHex(self)
    }

    func toUInt64AsHexClamped() -> UInt64AsHex {
        UInt64AsHex(clamping: self)
    }

    func toUInt128AsHex() -> UInt128AsHex? {
        UInt128AsHex(self)
    }

    func toUInt128AsHexClamped() -> UInt128AsHex {
        UInt128AsHex(clamping: self)
    }

    func toNumAsHex() -> NumAsHex? {
        NumAsHex(self)
    }
}
