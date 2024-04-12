import XCTest

@testable import Starknet

final class ByteArrayTests: XCTestCase {
    static let cases: [(String, StarknetByteArray)] = [
        ("hello", .init(data: [], pendingWord: "0x68656c6c6f", pendingWordLen: 5)!),
        ("Long string, more than 31 characters.", .init(data: ["0x4c6f6e6720737472696e672c206d6f7265207468616e203331206368617261"], pendingWord: "0x63746572732e", pendingWordLen: 6)!),
        ("ABCDEFGHIJKLMNOPQRSTUVWXYZ12345AAADEFGHIJKLMNOPQRSTUVWXYZ12345A", .init(data: ["0x4142434445464748494a4b4c4d4e4f505152535455565758595a3132333435", "0x4141414445464748494a4b4c4d4e4f505152535455565758595a3132333435"], pendingWord: "0x41", pendingWordLen: 1)!),
        ("ABCDEFGHIJKLMNOPQRSTUVWXYZ12345", .init(data: ["0x4142434445464748494a4b4c4d4e4f505152535455565758595a3132333435"], pendingWord: .zero, pendingWordLen: 0)!),
        ("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234", .init(data: [], pendingWord: "0x4142434445464748494a4b4c4d4e4f505152535455565758595a31323334", pendingWordLen: 30)!),
        ("", .init(data: [], pendingWord: .zero, pendingWordLen: 0)!),
    ]

    func testByteArrayFromString() {
        for (string, expected) in ByteArrayTests.cases {
            print(string)
            let actual = StarknetByteArray(fromString: string)
            XCTAssertEqual(actual, expected)
        }
    }

    func testExpressibleByStringLiteral() {
        let byteArray: StarknetByteArray = "hello"
        XCTAssertEqual(byteArray, StarknetByteArray(data: [], pendingWord: "0x68656c6c6f", pendingWordLen: 5))
    }

    func testInvalidByteArray() {
        XCTAssertNil(StarknetByteArray(data: [], pendingWord: "0x68656c6c6f", pendingWordLen: 31)) // pendingWordLen too big
        XCTAssertNil(StarknetByteArray(data: [], pendingWord: "0x68656c6c6f6", pendingWordLen: 4)) // pendingWordLen is not equal to the length of pendingWord
        XCTAssertNil(StarknetByteArray(data: ["0x4142434445464748494a4b4c4d4e4f505152535455565758595a3132333435", "0x68656c6c6f"], pendingWord: .zero, pendingWordLen: 0)) // Not all data elements have length 31
    }
}
