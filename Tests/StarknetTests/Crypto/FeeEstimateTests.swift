import XCTest

@testable import Starknet

final class FeeEstimateTests: XCTestCase {
    func testEstimateFeeToResourceBounds() {
        let cases: [(StarknetFeeEstimate, Double, Double, StarknetResourceBounds)] =
            [
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 2138, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 21390, feeUnit: .wei), 1.1, 1.5, StarknetResourceBounds(maxAmount: 11, maxPricePerUnit: 3207)),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 1000, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 10010, feeUnit: .wei), 1.0, 1.0, StarknetResourceBounds(maxAmount: 10, maxPricePerUnit: 1000)),
                (StarknetFeeEstimate(gasConsumed: Felt(UInt64AsHex.max.value - 100)!, gasPrice: Felt(UInt128AsHex.max.value - 100)!, dataGasConsumed: Felt.max, dataGasPrice: 10, overallFee: Felt.max, feeUnit: .wei), 1.1, 1.5, StarknetResourceBounds(maxAmount: UInt64AsHex.max, maxPricePerUnit: UInt128AsHex.max)),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 0, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 10, feeUnit: .wei), 1.5, 1.5, StarknetResourceBounds(maxAmount: 0, maxPricePerUnit: 0)),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 2000, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 20010, feeUnit: .wei), 2, 2, StarknetResourceBounds(maxAmount: 20, maxPricePerUnit: 4000)),
            ]

        cases.forEach {
            let resourceBounds = $0.toResourceBounds(amountMultiplier: $1, unitPriceMultiplier: $2)
            let expected = StarknetResourceBoundsMapping(l1Gas: $3)

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
                (StarknetFeeEstimate(gasConsumed: 1, gasPrice: 2138, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 2148, feeUnit: .wei), 1.1, 2362),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 1000, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 10010, feeUnit: .wei), 1.0, 10010),
                (StarknetFeeEstimate(gasConsumed: Felt(UInt64AsHex.max.value - 100)!, gasPrice: Felt(UInt128AsHex.max.value - 100)!, dataGasConsumed: 10, dataGasPrice: 1, overallFee: Felt.max, feeUnit: .wei), 1.1, Felt.max),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 0, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 0, feeUnit: .wei), 1.5, 0),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 2000, dataGasConsumed: 10, dataGasPrice: 1, overallFee: 20010, feeUnit: .wei), 2, 40020),
            ]

        cases.forEach {
            let estimated = $0.toMaxFee(multiplier: $1)
            XCTAssertEqual(estimated, $2)
        }
    }
}
