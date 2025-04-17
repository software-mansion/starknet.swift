import XCTest

@testable import Starknet

final class FeeEstimateTests: XCTestCase {
    let feeEstimate = StarknetFeeEstimate(
        l1GasConsumed: 10, l1GasPrice: 200, l2GasConsumed: 30, l2GasPrice: 400, l1DataGasConsumed: 50, l1DataGasPrice: 600, feeUnit: StarknetPriceUnit.fri
    )

    func testEstimateFeeToMaxFeeDefault() {
        let maxFee = feeEstimate?.toMaxFee()

        XCTAssertEqual(maxFee, 66000)
    }

    func testEstimateFeeToMaxFeeDefaultWithSpecificMultiplier() {
        let maxFee = feeEstimate?.toMaxFee(multiplier: 2)

        XCTAssertEqual(maxFee, 88000)
    }

    func testEstimateFeeToMaxFeeDefaultWithNeutralultiplier() {
        let maxFee = feeEstimate?.toMaxFee(multiplier: 1)

        XCTAssertEqual(maxFee, 44000)
    }

    func testEstimateFeeToResourceBoundsDefault() {
        let resourceBounds = feeEstimate?.toResourceBounds()

        let expected = StarknetResourceBoundsMapping(
            l1Gas: StarknetResourceBounds(maxAmount: 15, maxPricePerUnit: 300),
            l2Gas: StarknetResourceBounds(maxAmount: 45, maxPricePerUnit: 600),
            l1DataGas: StarknetResourceBounds(maxAmount: 75, maxPricePerUnit: 900)
        )
        XCTAssertEqual(resourceBounds!.l1Gas.maxAmount, expected.l1Gas.maxAmount)
        XCTAssertEqual(resourceBounds!.l1Gas.maxPricePerUnit, expected.l1Gas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!.l2Gas.maxAmount, expected.l2Gas.maxAmount)
        XCTAssertEqual(resourceBounds!.l2Gas.maxPricePerUnit, expected.l2Gas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!.l1DataGas.maxAmount, expected.l1DataGas.maxAmount)
        XCTAssertEqual(resourceBounds!.l1DataGas.maxPricePerUnit, expected.l1DataGas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!, expected)
    }

    func testEstimateFeeToResourceBoundsWithSpecificMultiplier() {
        let resourceBounds = feeEstimate?.toResourceBounds(amountMultiplier: 2, unitPriceMultiplier: 3)

        let expected = StarknetResourceBoundsMapping(
            l1Gas: StarknetResourceBounds(maxAmount: 20, maxPricePerUnit: 600),
            l2Gas: StarknetResourceBounds(maxAmount: 60, maxPricePerUnit: 1200),
            l1DataGas: StarknetResourceBounds(maxAmount: 100, maxPricePerUnit: 1800)
        )
        XCTAssertEqual(resourceBounds!.l1Gas.maxAmount, expected.l1Gas.maxAmount)
        XCTAssertEqual(resourceBounds!.l1Gas.maxPricePerUnit, expected.l1Gas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!.l2Gas.maxAmount, expected.l2Gas.maxAmount)
        XCTAssertEqual(resourceBounds!.l2Gas.maxPricePerUnit, expected.l2Gas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!.l1DataGas.maxAmount, expected.l1DataGas.maxAmount)
        XCTAssertEqual(resourceBounds!.l1DataGas.maxPricePerUnit, expected.l1DataGas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!, expected)
    }

    func testEstimateFeeToResourceBoundsWithNeutralMultiplier() {
        let resourceBounds = feeEstimate?.toResourceBounds(amountMultiplier: 1, unitPriceMultiplier: 1)

        let expected = StarknetResourceBoundsMapping(
            l1Gas: StarknetResourceBounds(maxAmount: 10, maxPricePerUnit: 200),
            l2Gas: StarknetResourceBounds(maxAmount: 30, maxPricePerUnit: 400),
            l1DataGas: StarknetResourceBounds(maxAmount: 50, maxPricePerUnit: 600)
        )
        XCTAssertEqual(resourceBounds!.l1Gas.maxAmount, expected.l1Gas.maxAmount)
        XCTAssertEqual(resourceBounds!.l1Gas.maxPricePerUnit, expected.l1Gas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!.l2Gas.maxAmount, expected.l2Gas.maxAmount)
        XCTAssertEqual(resourceBounds!.l2Gas.maxPricePerUnit, expected.l2Gas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!.l1DataGas.maxAmount, expected.l1DataGas.maxAmount)
        XCTAssertEqual(resourceBounds!.l1DataGas.maxPricePerUnit, expected.l1DataGas.maxPricePerUnit)
        XCTAssertEqual(resourceBounds!, expected)
    }
}
