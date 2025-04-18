import BigInt
import Foundation

public extension StarknetFeeEstimate {
    /// Convert estimated fee to resource bounds with applied multipliers
    ///
    /// Calculates max amount of l1 gas as `l1GasConsumed` * `amountMultiplier` and max price per unit as `l1GasPrice` * `unitPriceMultiplier`.
    /// Calculates max amount of l2 gas as `l2GasConsumed` * `amountMultiplier` and max price per unit as `l2GasPrice` * `unitPriceMultiplier`.
    /// Calculates max amount of l1 data gas as `l1DataGasConsumed` * `amountMultiplier` and max price per unit as `l1DataGasPrice` * `unitPriceMultiplier`.
    ///
    /// - Parameters:
    ///  - amountMultiplier: multiplier for max amount, defaults to 1.5.
    ///  - unitPriceMultiplier: multiplier for max price per unit, defaults to 1.5.
    ///
    /// - Returns: resource bounds with applied multipliers
    func toResourceBounds(amountMultiplier: Double = 1.5, unitPriceMultiplier: Double = 1.5) -> StarknetResourceBoundsMapping {
        let l1Gas = StarknetResourceBounds(
            maxAmount: self.l1GasConsumed.value.applyMultiplier(amountMultiplier).toUInt64AsHexClamped(),
            maxPricePerUnit: self.l1GasPrice.value.applyMultiplier(unitPriceMultiplier).toUInt128AsHexClamped()
        )
        let l2Gas = StarknetResourceBounds(
            maxAmount: self.l2GasConsumed.value.applyMultiplier(amountMultiplier).toUInt64AsHexClamped(),
            maxPricePerUnit: self.l2GasPrice.value.applyMultiplier(unitPriceMultiplier).toUInt128AsHexClamped()
        )
        let l1DataGas = StarknetResourceBounds(
            maxAmount: self.l1DataGasConsumed.value.applyMultiplier(amountMultiplier).toUInt64AsHexClamped(),
            maxPricePerUnit: self.l1DataGasPrice.value.applyMultiplier(unitPriceMultiplier).toUInt128AsHexClamped()
        )
        return StarknetResourceBoundsMapping(l1Gas: l1Gas, l2Gas: l2Gas, l1DataGas: l1DataGas)
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
