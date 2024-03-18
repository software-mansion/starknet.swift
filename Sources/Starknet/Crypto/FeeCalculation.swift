import BigInt
import Foundation

public extension StarknetFeeEstimate {
    /// Convert estimated fee to resource bounds with applied multipliers
    ///
    /// Calculates `maxAmount = overallFee / gasPrice`, unless `gasPrice` is 0, then `maxAmount` is 0.
    /// Calculates `maxPricePerUnit = gasPrice`.
    /// Then multiplies `maxAmount` by **round((amountMultiplier) \* 100%)** and `maxPricePerUnit` by **round((unitPriceMultiplier) \* 100%)** and performs integer division by 100 on both.
    ///
    /// - Parameters:
    ///  - amountMultiplier: Multiplier for max amount, defaults to 1.5.
    ///  - unitPriceMultiplier: Multiplier for max price per unit, defaults to 1.5.
    ///
    /// - Returns: Resource bounds with applied multipliers
    func toResourceBounds(amountMultiplier: Double = 1.5, unitPriceMultiplier: Double = 1.5) -> StarknetResourceBoundsMapping {
        let maxAmount = self.gasPrice == .zero ? UInt64AsHex.zero : (self.overallFee.value / self.gasPrice.value).applyMultiplier(amountMultiplier).toUInt64AsHexClamped()

        let maxUnitPrice = self.gasPrice.value.applyMultiplier(unitPriceMultiplier).toUInt128AsHexClamped()

        let l1Gas = StarknetResourceBounds(maxAmount: maxAmount, maxPricePerUnit: maxUnitPrice)
        return StarknetResourceBoundsMapping(l1Gas: l1Gas)
    }

    /// Convert estimated fee to max fee with applied multiplier.
    ///
    /// Multiplies `overallFee` by **round(multiplier] \* 100%)** and performs integer division by 100.
    ///
    /// - Parameters:
    ///  - multiplier: Multiplier for max fee, defaults to 1.5.
    ///
    /// - Returns: Fee with added overhead
    func toMaxFee(multiplier: Double = 1.5) -> Felt {
        self.overallFee.value.applyMultiplier(multiplier).toFeltClamped()
    }
}

private extension BigUInt {
    func applyMultiplier(_ multiplier: Double) -> BigUInt {
        let multiplier = BigUInt(Int(multiplier * 100))

        return self.multiplied(by: multiplier).quotientAndRemainder(dividingBy: 100).quotient
    }
}
