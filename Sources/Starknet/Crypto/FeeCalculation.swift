import BigInt
import Foundation

public extension StarknetFeeEstimate {
    /// Convert estimated fee to resource bounds with applied multipliers
    ///
    /// Calculates `maxAmountL1 = overallFee / l1GasPrice`, unless `l1GasPrice` is 0, then `maxAmountL1` is 0.
    /// Calculates `maxAmountL2 = overallFee / l2GasPrice`, unless `l2GasPrice` is 0, then `maxAmountL2` is 0.
    /// Calculates `maxPricePerUnitL1 = gasPriceL1`.
    /// Calculates `maxPricePerUnitL2 = gasPriceL2`.
    /// Then multiplies `maxAmountL1` and `maxAmountL2` by **round((amountMultiplier) \* 100)** and `maxPricePerUnitL1` and `maxPricePerUnitL2` by **round((unitPriceMultiplier) \* 100)** and performs integer division by 100 on each.
    ///
    ///
    /// - Parameters:
    ///  - amountMultiplier: multiplier for max amount, defaults to 1.5.
    ///  - unitPriceMultiplier: multiplier for max price per unit, defaults to 1.5.
    ///
    /// - Returns: resource bounds with applied multipliers
    func toResourceBounds(amountMultiplier: Double = 1.5, unitPriceMultiplier: Double = 1.5) -> StarknetResourceBoundsMapping {
        let maxAmountL1 = self.l1GasPrice == .zero ? UInt64AsHex.zero : (self.overallFee.value / self.l1GasPrice.value).applyMultiplier(amountMultiplier).toUInt64AsHexClamped()
        let maxAmountL2 = self.l2GasPrice == .zero ? UInt64AsHex.zero : (self.overallFee.value / self.l2GasPrice.value).applyMultiplier(amountMultiplier).toUInt64AsHexClamped()

        let maxUnitPriceL1 = self.l1GasPrice.value.applyMultiplier(unitPriceMultiplier).toUInt128AsHexClamped()
        let maxUnitPriceL2 = self.l2GasPrice.value.applyMultiplier(unitPriceMultiplier).toUInt128AsHexClamped()

        let l1Gas = StarknetResourceBounds(maxAmount: maxAmountL1, maxPricePerUnit: maxUnitPriceL1)
        let l2Gas = StarknetResourceBounds(maxAmount: maxAmountL2, maxPricePerUnit: maxUnitPriceL2)
        return StarknetResourceBoundsMapping(l1Gas: l1Gas, l2Gas: l2Gas)
    }

    /// Convert estimated fee to max fee with applied multiplier.
    ///
    /// Multiplies `overallFee` by **round(multiplier \* 100)** and performs integer division by 100.
    ///
    /// - Parameters:
    ///  - multiplier: multiplier for estimated fee, defaults to 1.5.
    ///
    /// - Returns: fee with applied multiplier
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
