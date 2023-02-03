import BigInt
import Foundation

/// Add overhead to estimated fee
///
/// Add overhead to estimated fee. Calculates multiplier as m = round((1 + ovehead) \* 100%).
/// Then multiplies fee by m and does integer division by 100.
///
/// - Parameters:
///  - fee: originally estimated fee
///  - overhead: how big overhead should be added (as a fraction of fee) to the fee, defaults to 0.1
/// - Returns: fee with added overhead
public func estimatedFeeToMaxFee(_ fee: Felt, overhead: Double = 0.1) -> Felt {
    let multiplier = BigUInt(Int((1.0 + overhead) * 100))

    let value = fee.value.multiplied(by: multiplier).quotientAndRemainder(dividingBy: 100).quotient

    return Felt(clamping: value)
}
