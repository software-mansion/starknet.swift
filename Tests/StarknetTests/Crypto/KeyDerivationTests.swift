import XCTest
import BigInt
@testable import Starknet

final class KeyDerivationTests: XCTestCase {
    private let curveOrder = StarknetCurve.curveOrder

    func testGrindKeyIsDeterministicAndInRange() throws {
        let seed = Data([0xde, 0xad, 0xbe, 0xef])
        let k1 = try StarkKeygen.grindKey(seed: seed)
        let k2 = try StarkKeygen.grindKey(seed: seed)
        XCTAssertEqual(k1, k2)
        XCTAssertTrue(k1 < curveOrder)
        XCTAssertNotEqual(k1, 0)
    }

    func testRandomPrivateKeyLooksValid() throws {
        let hex = try StarkKeygen.randomPrivateKeyHex()
        XCTAssertTrue(hex.hasPrefix("0x"))
        XCTAssertEqual(hex.count, 2 + 64)
        let sk = BigUInt(hex.dropFirst(2), radix: 16)!
        XCTAssertTrue(sk < curveOrder)
        XCTAssertNotEqual(sk, 0)
        let hex2 = try StarkKeygen.randomPrivateKeyHex()
        XCTAssertNotEqual(hex, hex2)
    }

}

fileprivate extension String {
    func leftPadding(width: Int) -> String {
        if count >= width { return self }
        return String(repeating: "0", count: width - count) + self
    }
}
