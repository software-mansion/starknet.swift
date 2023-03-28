import XCTest

@testable import Starknet

private typealias ChecksumTestCase = (
    notFormatted: String,
    formatted: String
)

let checksumAddresses = [
    // List of (address, valid checksum address)
    // Correct values generated with starknet.js and stolen from starknet-jvm
    ChecksumTestCase(
        "0x2fd23d9182193775423497fc0c472e156c57c69e4089a1967fb288a2d84e914",
        "0x02Fd23d9182193775423497fc0c472E156C57C69E4089A1967fb288A2d84e914"
    ),
    ChecksumTestCase(
        "0x00abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefab",
        "0x00AbcDefaBcdefabCDEfAbCDEfAbcdEFAbCDEfabCDefaBCdEFaBcDeFaBcDefAb"
    ),
    ChecksumTestCase(
        "0xfedcbafedcbafedcbafedcbafedcbafedcbafedcbafedcbafedcbafedcbafe",
        "0x00fEdCBafEdcbafEDCbAFedCBAFeDCbafEdCBAfeDcbaFeDCbAfEDCbAfeDcbAFE"
    ),
    ChecksumTestCase(
        "0xa",
        "0x000000000000000000000000000000000000000000000000000000000000000A"
    ),
    ChecksumTestCase(
        "0x0",
        "0x0000000000000000000000000000000000000000000000000000000000000000"
    ),
]

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

    func testIsChecksumAddressValid() {
        for testCase in checksumAddresses {
            let felt = Felt(fromHex: testCase.notFormatted)!
            let formatted = StarknetContractAddressCalculator.calculateChecksumAddress(address: felt)
            XCTAssertEqual(formatted, testCase.formatted)
        }
    }
}
