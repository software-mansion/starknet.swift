import BigInt
import Foundation

public extension BigUInt {
    func toFelt() -> Felt? {
        Felt(self)
    }

    func toFeltClamped() -> Felt {
        self > Felt.max.value ? Felt.max : Felt(self)!
    }
    
    func toNumAsHex() -> NumAsHex? {
        NumAsHex(self)
    }
}
