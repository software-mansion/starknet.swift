import XCTest

import BigInt

@testable import Starknet

final class FeltTests: XCTestCase {
    static let casesCount = 1000

    static var feltCases: [(String, Felt)] = []
    static var numAsHexCases: [(String, NumAsHex)] = []

    override class func setUp() {
        self.feltCases = Array(repeating: 0, count: casesCount).map { _ -> (String, Felt) in
            let uint = BigUInt.randomInteger(lessThan: Felt.prime)
            let bigUint = NumAsHex(Felt.prime + uint)

            let hexString = "0x\(String(uint, radix: 16))"
            let felt = Felt(uint)!
            return (hexString, felt)
        }

        self.numAsHexCases = Array(repeating: 0, count: casesCount).map { index -> (String, NumAsHex) in
            let uint = BigUInt.randomInteger(lessThan: Felt.prime)
            let bigUint = Felt.prime + uint

            let hexString = "0x\(String(uint, radix: 16))"
            let numAsHex = index % 2 == 0 ? NumAsHex(uint)! : NumAsHex(bigUint)!
            return (hexString, numAsHex)
        }
    }

    func testOverflow() {
        let bigNumber = BigUInt(2).power(252)
        XCTAssertNil(Felt(bigNumber))
        XCTAssertNotNil(NumAsHex(bigNumber))
    }

    func testUnderflow() {
        let negative: Int = -5

        XCTAssertNil(Felt(negative))
    }

    func testFromHexInitializer() {
        FeltTests.feltCases.forEach {
            XCTAssertEqual(Felt(fromHex: $0), $1)
        }
        FeltTests.numAsHexCases.forEach {
            XCTAssertEqual(NumAsHex(fromHex: $0), $1)
        }
    }

    func testClampingInitializer() {
        let a: Int = -32

        XCTAssertEqual(Felt(clamping: a), 0)

        let b: UInt = 999_999

        XCTAssertEqual(Felt(clamping: b), 999_999)
    }

    func testFeltComparison() {
        XCTAssertTrue(Felt(10) < Felt(20))
        XCTAssertTrue(Felt(100) == Felt(100))
        XCTAssertTrue(Felt(100) <= Felt(100))
        XCTAssertFalse(Felt(0) > Felt(99))
    }

    func testNumAsHexComparison() {
        XCTAssertTrue(NumAsHex(10) < NumAsHex(20))
        XCTAssertTrue(NumAsHex(100) == NumAsHex(100))
        XCTAssertTrue(NumAsHex(100) <= NumAsHex(100))
        XCTAssertFalse(NumAsHex(0) > NumAsHex(99))
    }

    func testNumAsHexProtocolComparison() {
        XCTAssertTrue(NumAsHex(10) < Felt(20))
        XCTAssertTrue(Felt(10) < NumAsHex(20))
        XCTAssertTrue(Felt(10) == NumAsHex(10))
        XCTAssertTrue(NumAsHex(10) == Felt(10))
        XCTAssertTrue(NumAsHex(100) <= Felt(100))
        XCTAssertTrue(Felt(100) <= NumAsHex(100))
    }

    func testFeltDecoding() {
        do {
            try FeltTests.feltCases.forEach {
                let data = Data("\"\($0)\"".utf8)
                let felt = try JSONDecoder().decode(Felt.self, from: data)

                XCTAssertEqual(felt, $1)
            }
        } catch {
            XCTFail("Decoding failed")
        }
    }

    func testNumAsHexDecoding() {
        do {
            try FeltTests.numAsHexCases.forEach {
                let data = Data("\"\($0)\"".utf8)
                let numAsHex = try JSONDecoder().decode(NumAsHex.self, from: data)

                XCTAssertEqual(numAsHex, $1)
            }
        } catch {
            XCTFail("Decoding failed")
        }
    }

    func testFeltEncoding() {
        do {
            try FeltTests.feltCases.forEach {
                let data = try JSONEncoder().encode($1)
                let expectedData = Data("\"\($0)\"".utf8)
                XCTAssertEqual(data, expectedData)
            }
        } catch {
            XCTFail("Encoding failed")
        }
    }

    func testNumAsHexEncoding() {
        do {
            try FeltTests.numAsHexCases.forEach {
                let data = try JSONEncoder().encode($1)
                let expectedData = Data("\"\($0)\"".utf8)
                XCTAssertEqual(data, expectedData)
            }
        } catch {
            XCTFail("Encoding failed")
        }
    }

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
