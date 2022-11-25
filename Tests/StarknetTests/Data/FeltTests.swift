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
    
    func testAddition() {
        let cases = [
            (Felt(5), Felt(10), Felt(15)),
            (Felt.max, Felt(1), Felt(0)),
            (Felt.max, Felt.max, Felt(Felt.prime - 2))
        ]
        
        cases.forEach {
            XCTAssertEqual($0 + $1, $2)
        }
    }
    
    func testSubtraction() {
        let cases = [
            (Felt(10), Felt(5), Felt(5)),
            (Felt(10), Felt(10), Felt(0)),
            (Felt(5), Felt(6), Felt.max),
            (Felt(Felt.prime - 2)!, Felt.max, Felt.max)
        ]
        
        cases.forEach {
            XCTAssertEqual($0 - $1, $2)
        }
    }
    
    func testMultiplication() {
        let cases = [
            (Felt(10), Felt(20), Felt(200)),
            (Felt.max, Felt.zero, Felt.zero),
            (Felt.max, Felt(5), Felt.max - 4)
        ]
        
        cases.forEach {
            XCTAssertEqual($0 * $1, $2)
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
}
