import BigInt
import Foundation

/// Convert estimated fee to max fee with added overhead
///
/// Add overhead to estimated fee. Calculates multiplier as m = round((1 + ovehead) \* 100%).
/// Then multiplies fee by m and does integer division by 100.
///
/// - Parameters:
///  - fee: originally estimated fee
///  - overhead: how big overhead should be added (as a fraction of fee) to the fee, defaults to 0.5
/// - Returns: max fee with added overhead
public func estimatedFeeToMaxFee(_ fee: Felt, overhead: Double = 0.5) -> Felt {
    addOverhead(fee.value, overhead).toFeltClamped()
}

public extension StarknetFeeEstimate {
    /// Convert estimated fee to resource bounds with added overhead
    ///
    /// Add overhead to estimated fee. Calculates multiplier as m = round((1 + ovehead) \* 100%).
    /// Then multiplies fee by m and does integer division by 100.
    ///
    /// - Parameters:
    ///  - amountOverhead: how big overhead should be added (as a fraction of amount) to the amount, defaults to 0.1
    ///  - unitPriceOverhead: how big overhead should be added (as a fraction of unit price) to the unit price, defaults to 0.5
    /// - Returns: resource bounds with added overhead
    func toResourceBounds(amountOverhead: Double = 0.1, unitPriceOverhead: Double = 0.5) -> StarknetResourceBoundsMapping {
        let maxAmount = addOverhead(self.gasConsumed.value, amountOverhead).toUInt64AsHexClamped()
        let maxUnitPrice = addOverhead(self.gasPrice.value, unitPriceOverhead).toUInt128AsHexClamped()

        let l1Gas = StarknetResourceBounds(maxAmount: maxAmount, maxPricePerUnit: maxUnitPrice)
        return StarknetResourceBoundsMapping(l1Gas: l1Gas)
    }

    func toMaxFee(overhead: Double = 0.5) -> Felt {
        addOverhead(self.overallFee.value, overhead).toFeltClamped()
    }
}

private func addOverhead(_ value: BigUInt, _ overhead: Double) -> BigUInt {
    let multiplier = BigUInt(Int((1.0 + overhead) * 100))

    return value.multiplied(by: multiplier).quotientAndRemainder(dividingBy: 100).quotient
}
