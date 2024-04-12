import XCTest

@testable import Starknet

final class SelectorTests: XCTestCase {
    func testSelector() {
        let cases = [
            ("test", "0x22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658"),
            ("initialize", "0x79dc0da7c54b95f10aa182ad0a46400db63156920adb65eca2654c0945a463"),
            ("mint", "0x2f0b3c5710379609eb5495f1ecd348cb28167711b73609fe565a72734550354"),
            ("__default__", "0x0"),
            ("__l1_default__", "0x0"),
        ]

        for (name, hex) in cases {
            XCTAssertEqual(starknetSelector(from: name), Felt(fromHex: hex))
        }
    }
}
