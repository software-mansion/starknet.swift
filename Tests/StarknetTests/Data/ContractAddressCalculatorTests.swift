import XCTest

@testable import Starknet

final class ContractAddressCalculatorTests: XCTestCase {
    func testCalculateFrom() {
        let classHash = Felt("951442054899045155353616354734460058868858519055082696003992725251069061570")
        let constructorCalldata = [Felt(21), Felt(37)]
        let salt = Felt(1111)

        let addressWithoutDeployer = StarknetContractAddressCalculator.calculateFrom(classHash: classHash, calldata: constructorCalldata, salt: salt)

        XCTAssertEqual(Felt("1357105550695717639826158786311415599375114169232402161465584707209611368775"), addressWithoutDeployer)

        let addressWithDeployer = StarknetContractAddressCalculator.calculateFrom(classHash: classHash, calldata: constructorCalldata, salt: salt, deployerAddress: 1234)

        XCTAssertEqual(Felt("3179899882984850239687045389724311807765146621017486664543269641150383510696"), addressWithDeployer)
    }
}
