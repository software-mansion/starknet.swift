import XCTest

import BigInt

@testable import CryptoToolkit
@testable import Starknet

final class PoseidonTests: XCTestCase {
    func testPoseidonHashDoubleBigNumbers() {
        let value = Felt(BigUInt("737869762948382064636737869762948382064636737869762948382064636"))!
        let result = Poseidon.poseidonHash(x: value, y: value)
        XCTAssertEqual(result, Felt(fromHex: "0x59c0ba54a2613d811726e10be9d6f7e01cf52d6d68ced0d16829027948cdfc3")!)
    }
}
