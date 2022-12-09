import XCTest

import BigInt

@testable import Starknet

final class FeltTests: XCTestCase {
    
    static let casesCount = 1000
    
    static var cases: [(String, Felt)] = []
    
    override class func setUp() {
        self.cases = Array(repeating: 0, count: casesCount).map { _ -> (String, Felt) in
            let uint = BigUInt.randomInteger(lessThan: Felt.prime)
            
            let hexString = "0x\(String(uint, radix: 16))"
            let felt = Felt(uint)!
            
            return (hexString, felt)
        }
    }
    
    func testTooBigValue() {
        let bigNumber = BigUInt(2).power(252)
        
        let felt = Felt(bigNumber)
        XCTAssertNil(felt)
    }
    
    func testFromHexInitializer() {
        FeltTests.cases.forEach {
            XCTAssertEqual(Felt(fromHex: $0), $1)
        }
    }
    
    func testFeltComparison() {
        XCTAssertTrue(Felt(10)! < Felt(20)!)
        XCTAssertTrue(Felt(100)! <= Felt(100)!)
        XCTAssertFalse(Felt(0)! > Felt(99)!)
    }
    
    func testFeltDecoding() {
        do {
            try FeltTests.cases.forEach {
                let data = Data("\"\($0)\"".utf8)
                let felt = try JSONDecoder().decode(Felt.self, from: data)
                
                XCTAssertEqual(felt, $1)
            }
        } catch {
            XCTFail("Decoding failed")
        }
    }
    
    func testFeltEncoding() {
        do {
            try FeltTests.cases.forEach {
                let data = try JSONEncoder().encode($1)
                let expectedData = Data("\"\($0)\"".utf8)
                XCTAssertEqual(data, expectedData)
            }
        } catch {
            XCTFail("Encoding failed")
        }
        
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
