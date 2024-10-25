import XCTest

@testable import Starknet

final class FeeEstimateTests: XCTestCase {
    func testEstimateFeeToResourceBounds() {
        let cases: [(StarknetFeeEstimate, Double, Double, StarknetResourceBounds)] =
            [
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 2138, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 21390, feeUnit: .wei), 1.1, 1.5, StarknetResourceBounds(maxAmount: 11, maxPricePerUnit: 3207)),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 1000, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 10010, feeUnit: .wei), 1.0, 1.0, StarknetResourceBounds(maxAmount: 10, maxPricePerUnit: 1000)),
                (StarknetFeeEstimate(l1GasConsumed: Felt(UInt64AsHex.max.value - 100)!, l1GasPrice: Felt(UInt128AsHex.max.value - 100)!, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: Felt.max, l1DataGasPrice: 10, overallFee: Felt.max, feeUnit: .wei), 1.1, 1.5, StarknetResourceBounds(maxAmount: UInt64AsHex.max, maxPricePerUnit: UInt128AsHex.max)),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 0, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 10, feeUnit: .wei), 1.5, 1.5, StarknetResourceBounds(maxAmount: 0, maxPricePerUnit: 0)),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 2000, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 20010, feeUnit: .wei), 2, 2, StarknetResourceBounds(maxAmount: 20, maxPricePerUnit: 4000)),
            ]

        cases.forEach {
            let resourceBounds = $0.toResourceBounds(amountMultiplier: $1, unitPriceMultiplier: $2)
            let expected = StarknetResourceBoundsMapping(l1Gas: $3, l2Gas: StarknetResourceBounds.zero)

            XCTAssertEqual(resourceBounds.l1Gas.maxAmount, expected.l1Gas.maxAmount)
            XCTAssertEqual(resourceBounds.l1Gas.maxPricePerUnit, expected.l1Gas.maxPricePerUnit)
            XCTAssertEqual(resourceBounds.l2Gas.maxAmount, expected.l2Gas.maxAmount)
            XCTAssertEqual(resourceBounds.l2Gas.maxPricePerUnit, expected.l2Gas.maxPricePerUnit)
            XCTAssertEqual(resourceBounds, expected)
        }
    }

    func testEstimateFeeToMaxFee() {
        let cases: [(StarknetFeeEstimate, Double, Felt)] =
            [
                (StarknetFeeEstimate(l1GasConsumed: 1, l1GasPrice: 2138, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 2148, feeUnit: .wei), 1.1, 2362),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 1000, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 10010, feeUnit: .wei), 1.0, 10010),
                (StarknetFeeEstimate(l1GasConsumed: Felt(UInt64AsHex.max.value - 100)!, l1GasPrice: Felt(UInt128AsHex.max.value - 100)!, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: Felt.max, feeUnit: .wei), 1.1, Felt.max),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 0, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 10, feeUnit: .wei), 1.5, 15),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 2000, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, overallFee: 20010, feeUnit: .wei), 2, 40020),
            ]

        cases.forEach {
            let estimated = $0.toMaxFee(multiplier: $1)
            XCTAssertEqual(estimated, $2)
        }
    }

    func testEstimateFeeOverallFeeCalculation() {
        let cases: [(StarknetFeeEstimate, Felt)] =
            [
                (StarknetFeeEstimate(l1GasConsumed: 1, l1GasPrice: 2138, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, feeUnit: .wei)!, 2148),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 1000, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, feeUnit: .wei)!, 10010),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 0, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, feeUnit: .wei)!, 10),
                (StarknetFeeEstimate(l1GasConsumed: 10, l1GasPrice: 2000, l2GasConsumed: 0, l2GasPrice: 0, l1DataGasConsumed: 10, l1DataGasPrice: 1, feeUnit: .wei)!, 20010),
            ]

        cases.forEach {
            let calculatedOverallFee = $0.overallFee
            XCTAssertEqual(calculatedOverallFee, $1)
        }
    }
}
