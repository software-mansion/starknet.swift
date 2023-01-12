import XCTest
@testable import Starknet

final class devnetClientTests: XCTestCase {
    func testExample() async throws {
        let test = DevnetClient()
        test.start()
        //test.prefundAccount(accountAddress: "0x0172d1a003a779c48e66a1b9e591094105d9c48ebc335c44e92faa9197e495cb")
        test.deployAccount(name: "test1234")
        print(test.readAccountDetails(accountName: "test1234"))
        sleep(5)
        
        // You can check that its alive with 'curl http://127.0.0.1:5050/is_alive' in the console
        test.close()
        // After closing the command above will return an error
    }
}
