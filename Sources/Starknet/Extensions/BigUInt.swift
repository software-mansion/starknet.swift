import Foundation
import BigInt

public extension BigUInt {
    func toFelt() -> Felt? {
        return Felt(self)
    }
    
    func toFeltClamped() -> Felt {
        return self > Felt.max.value ? Felt.max : Felt(self)!
    }
}
