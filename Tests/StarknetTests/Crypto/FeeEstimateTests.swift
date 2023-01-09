import XCTest

@testable import Starknet

final class FeeEstimateTests: XCTestCase {
    func testEstimatedFeeToMaxFee() {
        let cases: [(Felt, Double, Felt)] = [
            (2138, 0.1, 2351),
            (1000, 0, 1000),
            (Felt(Felt.max.value - 100)!, 0.1, Felt.max),
            (0, 0.5, 0),
            (2000, 1, 4000)
        ]
        
        cases.forEach {
            let estimated = estimatedFeeToMaxFee($0, overhead: $1)
            
            XCTAssertEqual(estimated, $2)
        }
        
    }
}
