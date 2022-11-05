import XCTest

import BigInt

@testable import Starknet

final class FeltTests: XCTestCase {
    
    func testTooBigValue() {
        let bigNumber = BigUInt(2).power(252)
        
        let felt = Felt(bigNumber)
        XCTAssertNil(felt)
    }
    
    func testFromHexInitializer() {
        let cases = [
            ("0x0", Felt(0)),
            ("0xa", Felt(10)),
            ("0xAAA", Felt(2730)),
        ]
        
        cases.forEach {
            XCTAssertEqual(Felt(fromHex: $0), $1)
        }
    }
    
    func testFeltDescription() {
        let cases = [
            (Felt(10)!, "0xa"),
            (Felt(100)!, "0x64"),
            (Felt(2137)!, "0x859")
        ]
        
        cases.forEach {
            XCTAssertEqual(String(describing: $0), $1)
        }
    }
}
