import XCTest

import BigInt

@testable import Starknet

final class FeltTests: XCTestCase {
    func testExpressibleByStringLiteral() {
        let felt1: Felt = "0x123"
        let numAsHex1: NumAsHex = "0x123"
        XCTAssertEqual(felt1, Felt(0x123))
        XCTAssertEqual(numAsHex1, NumAsHex(0x123))

        let felt2: Felt = "0x0"
        let numAsHex2: NumAsHex = "0x0"
        XCTAssertEqual(felt2, Felt.zero)
        XCTAssertEqual(numAsHex2, NumAsHex.zero)

        let felt3: Felt = "7312"
        let numAsHex3: NumAsHex = "7312"
        XCTAssertEqual(felt3, Felt(7312))
        XCTAssertEqual(numAsHex3, NumAsHex(7312))

        let felt4: Felt = "0"
        let numAsHex4: NumAsHex = "0"
        XCTAssertEqual(felt4, Felt(0))
        XCTAssertEqual(numAsHex4, NumAsHex(0))
    }

    func testFromSigned() {
        XCTAssertEqual(Felt(fromSigned: -1), Felt.max)
        XCTAssertEqual(Felt(fromSigned: -BigInt(Felt.max.value)), Felt.one)
        XCTAssertEqual(
            Felt(fromSigned: -Int.max),
            Felt(BigInt(Felt.prime) - BigInt(Int.max))
        )
        XCTAssertEqual(
            Felt(fromSigned: -Int64.max),
            Felt(BigInt(Felt.prime) - BigInt(Int64.max))
        )
        XCTAssertNil(Felt(fromSigned: Felt.prime))
        XCTAssertNil(Felt(fromSigned: -BigInt(Felt.prime)))
    }

    func testShortStringEncoding() {
        let encoded = Felt(fromHex: "0x68656c6c6f")!.toShortString()

        XCTAssertEqual("hello", encoded)

        let encoded_padding = Felt(fromHex: "0xa68656c6c6f")!.toShortString()

        XCTAssertEqual(encoded_padding, "\nhello")
    }

    func testShortStringDecoding() {
        let decoded = Felt.fromShortString("hello")

        XCTAssertEqual(decoded, Felt(fromHex: "0x68656c6c6f")!)

        let decodedEmptyString = Felt.fromShortString("")

        XCTAssertEqual(decodedEmptyString, Felt.zero)

        let decodedTooLong = Felt.fromShortString(String(repeating: "a", count: 32))

        XCTAssertNil(decodedTooLong)

        let decodedNonAscii = Felt.fromShortString("hello😀")

        XCTAssertNil(decodedNonAscii)
    }
}
