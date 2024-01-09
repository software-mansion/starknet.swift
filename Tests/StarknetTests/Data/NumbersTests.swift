import XCTest

import BigInt

@testable import Starknet

final class NumbersTests: XCTestCase {
    static let casesCount = 1000

    static var feltCases: [(String, Felt)] = []
    static var uInt64Cases: [(String, UInt64AsHex)] = []
    static var uInt128Cases: [(String, UInt128AsHex)] = []
    static var numAsHexCases: [(String, NumAsHex)] = []
    static var allCases: [[(String, any NumAsHexProtocol)]] = [feltCases, numAsHexCases, uInt64Cases, uInt128Cases]

    override class func setUp() {
        self.feltCases = Array(repeating: 0, count: casesCount).map { _ -> (String, Felt) in
            let uint = BigUInt.randomInteger(lessThan: Felt.prime)
            let hexString = "0x\(String(uint, radix: 16))"

            return (hexString, Felt(uint)!)
        }
        self.uInt64Cases = Array(repeating: 0, count: casesCount).map { _ -> (String, UInt64AsHex) in
            let uint = UInt64.random(in: 1 ... UInt64.max)
            let hexString = "0x\(String(uint, radix: 16))"

            return (hexString, UInt64AsHex(uint)!)
        }
        self.uInt128Cases = Array(repeating: 0, count: casesCount).map { _ -> (String, UInt128AsHex) in
            let uint = BigUInt.randomInteger(lessThan: UInt128AsHex.max.value)
            let hexString = "0x\(String(uint, radix: 16))"

            return (hexString, UInt128AsHex(uint)!)
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
        let overFelt = BigUInt(2).power(252)
        let overUInt128 = BigInt(2).power(128)
        let overUInt64 = BigInt(2).power(64)
        XCTAssertNil(Felt(overFelt))
        XCTAssertNil(UInt128AsHex(overUInt128))
        XCTAssertNil(UInt64AsHex(overUInt64))
        XCTAssertNotNil(NumAsHex(overFelt))
    }

    func testUnderflow() {
        let negative: Int = -5

        XCTAssertNil(NumAsHex(negative))
        XCTAssertNil(Felt(negative))
        XCTAssertNil(UInt128AsHex(negative))
        XCTAssertNil(UInt64AsHex(negative))
    }

    func testFromHexInitializer() {
        NumbersTests.feltCases.forEach {
            XCTAssertEqual(Felt(fromHex: $0), $1)
        }
        NumbersTests.uInt64Cases.forEach {
            XCTAssertEqual(UInt64AsHex(fromHex: $0), $1)
        }
        NumbersTests.uInt128Cases.forEach {
            XCTAssertEqual(UInt128AsHex(fromHex: $0), $1)
        }
        NumbersTests.numAsHexCases.forEach {
            XCTAssertEqual(NumAsHex(fromHex: $0), $1)
        }
    }

    func testClampingInitializer() {
        let a: Int = -32
        XCTAssertEqual(Felt(clamping: a).value, 0)

        let b: UInt = 999_999
        XCTAssertEqual(Felt(clamping: b).value, 999_999)

        let c = Felt.prime
        XCTAssertEqual(Felt(clamping: c).value, Felt.prime - 1)

        let d = BigUInt(UInt64.max) + 1
        XCTAssertEqual(UInt64AsHex(clamping: d), UInt64AsHex.max)

        let e = UInt128AsHex.max.value + 1
        XCTAssertEqual(UInt128AsHex(clamping: e), UInt128AsHex.max)
    }

    func testFeltComparison() {
        XCTAssertTrue(Felt(10) < Felt(20))
        XCTAssertTrue(Felt(100) == Felt(100))
        XCTAssertTrue(Felt(100) <= Felt(100))
        XCTAssertFalse(Felt(0) > Felt(99))
    }

    func testNumAsHexProtocolComparison() {
        XCTAssertTrue(NumAsHex(10) < Felt(20))
        XCTAssertTrue(Felt(10) < NumAsHex(20))
        XCTAssertTrue(Felt(10) == NumAsHex(10))
        XCTAssertTrue(NumAsHex(10) == Felt(10))
        XCTAssertTrue(NumAsHex(100) <= Felt(100))
        XCTAssertTrue(Felt(100) <= NumAsHex(100))
    }

    func testDecodingType<T: NumAsHexProtocol>(cases: [(String, T)]) {
        do {
            try cases.forEach {
                let data = Data("\"\($0)\"".utf8)
                let decodedValue = try JSONDecoder().decode(T.self, from: data)

                XCTAssertEqual(decodedValue, $1)
            }
        } catch {
            XCTFail("Decoding failed")
        }
    }

    func testDecoding() {
        testDecodingType(cases: NumbersTests.feltCases)
        testDecodingType(cases: NumbersTests.uInt64Cases)
        testDecodingType(cases: NumbersTests.uInt128Cases)
        testDecodingType(cases: NumbersTests.numAsHexCases)
    }

    func testEncoding() {
        for cases in NumbersTests.allCases {
            for (hexString, num) in cases {
                do {
                    let data = try JSONEncoder().encode(num)
                    let expectedData = Data("\"\(hexString)\"".utf8)
                    XCTAssertEqual(data, expectedData)
                } catch {
                    XCTFail("Encoding failed for \(hexString)")
                }
            }
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
