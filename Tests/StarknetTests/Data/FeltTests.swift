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
    
    func testOverAndUnderflow() {
        let bigNumber = BigUInt(2).power(252)
        
        XCTAssertNil(Felt(bigNumber))
        
        let negative: Int = -5
        
        XCTAssertNil(Felt(negative))
    }
    
    func testFromHexInitializer() {
        FeltTests.cases.forEach {
            XCTAssertEqual(Felt(fromHex: $0), $1)
        }
    }
    
    func testClampingInitializer() {
        let a: Int = -32
        
        XCTAssertEqual(Felt(clamping: a), 0)
        
        let b: UInt = 999999
        
        XCTAssertEqual(Felt(clamping: b), 999999)
    }
    
    func testFeltComparison() {
        XCTAssertTrue(Felt(10) < Felt(20))
        XCTAssertTrue(Felt(100) <= Felt(100))
        XCTAssertFalse(Felt(0) > Felt(99))
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
    
    func testExpressibleByStringLiteral() {
        let felt1: Felt = "0x123"
        XCTAssertEqual(felt1, Felt(0x123))
        
        let felt2: Felt = "0x0"
        XCTAssertEqual(felt2, Felt.zero)
        
        
        let felt3: Felt = "7312"
        XCTAssertEqual(felt3, Felt(7312))
        
        let felt4: Felt = "0"
        XCTAssertEqual(felt4, Felt(0))
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
