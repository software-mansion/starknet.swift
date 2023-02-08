@testable import Starknet
import XCTest

final class devnetClientTests: XCTestCase {
    var client: DevnetClientProtocol!

    override func setUp() async throws {
        client = try makeDevnetClient()
        try await client.start()
    }

    override func tearDown() async throws {
        client.close()
    }

    func testDeployAccount() async throws {
        let _ = try await client.deployAccount(name: "Account1")
        let _ = try await client.deployAccount()
    }
}
