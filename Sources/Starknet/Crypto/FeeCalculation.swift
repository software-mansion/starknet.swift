import Foundation
import BigInt

public func estimatedFeeToMaxFee(_ fee: Felt, overhead: Double = 0.1) -> Felt {
    let multiplier = BigUInt(Int(((1.0 + overhead) * 100)))
    
    let value = fee.value.multiplied(by: multiplier).quotientAndRemainder(dividingBy: 100).quotient
    
    return Felt(clamping: value)
}
