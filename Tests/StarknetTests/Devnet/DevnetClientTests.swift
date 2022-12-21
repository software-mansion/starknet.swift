import XCTest
@testable import Starknet

final class testnetTests: XCTestCase {
    func testExample() throws {
        let test = DevnetClient()
        test.start()
        test.close()
    }
}

