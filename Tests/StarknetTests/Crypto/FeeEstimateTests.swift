import XCTest

@testable import Starknet

final class FeeEstimateTests: XCTestCase {
    func testEstimateFeeToResourceBounds() {
        let cases: [(StarknetFeeEstimate, Double, Double, StarknetResourceBounds)] =
            [
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 2138, overallFee: 21380, feeUnit: .wei), 0.1, 0.5, StarknetResourceBounds(maxAmount: 11, maxPricePerUnit: 3207)),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 1000, overallFee: 10000, feeUnit: .wei), 0, 0, StarknetResourceBounds(maxAmount: 10, maxPricePerUnit: 1000)),
                (StarknetFeeEstimate(gasConsumed: Felt(UInt64AsHex.max.value - 100)!, gasPrice: Felt(UInt128AsHex.max.value - 100)!, overallFee: Felt.max, feeUnit: .wei), 0.1, 0.5, StarknetResourceBounds(maxAmount: UInt64AsHex.max, maxPricePerUnit: UInt128AsHex.max)),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 0, overallFee: 0, feeUnit: .wei), 0.5, 0.5, StarknetResourceBounds(maxAmount: 15, maxPricePerUnit: 0)),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 2000, overallFee: 20000, feeUnit: .wei), 1, 1, StarknetResourceBounds(maxAmount: 20, maxPricePerUnit: 4000)),
            ]

        cases.forEach {
            let resourceBounds = $0.toResourceBounds(amountOverhead: $1, unitPriceOverhead: $2)
            let expected = StarknetResourceBoundsMapping(l1Gas: $3)
            XCTAssertEqual(resourceBounds, expected)
        }
    }

    func testEstimateFeeToMaxFee() {
        let cases: [(StarknetFeeEstimate, Double, Felt)] =
            [
                (StarknetFeeEstimate(gasConsumed: 1, gasPrice: 2138, overallFee: 2138, feeUnit: .wei), 0.1, 2351),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 1000, overallFee: 10000, feeUnit: .wei), 0, 10000),
                (StarknetFeeEstimate(gasConsumed: Felt(UInt64AsHex.max.value - 100)!, gasPrice: Felt(UInt128AsHex.max.value - 100)!, overallFee: Felt.max, feeUnit: .wei), 0.1, Felt.max),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 0, overallFee: 0, feeUnit: .wei), 0.5, 0),
                (StarknetFeeEstimate(gasConsumed: 10, gasPrice: 2000, overallFee: 20000, feeUnit: .wei), 1, 40000),
            ]

        cases.forEach {
            let estimated = $0.toMaxFee(overhead: $1)
            XCTAssertEqual(estimated, $2)
        }
    }
}
