import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
    /*
     Temporary test file, until DevnetClient utility is created.

     To run, make sure you're running starknet-devnet on port 5050, with seed 0
     */
    static var devnetClient: DevnetClientProtocol!
    var provider: StarknetProviderProtocol!

    override class func setUp() {
        print("Before class set up")
        super.setUp()
        devnetClient = makeDevnetClient()
        print("After class set up")
    }

    override class func tearDown() {
        print("Before class tear down")
        super.tearDown()
        devnetClient.close()
        print("After class tear down")
    }

    override func setUp() async throws {
        print("Before local set up")
        try await super.setUp()

        if !Self.devnetClient.isRunning() {
            try await Self.devnetClient.start()
        }

        provider = makeStarknetProvider(url: Self.devnetClient.rpcUrl)
        print("After local set up")
    }

    func makeStarknetProvider(url: String) -> StarknetProviderProtocol {
        StarknetProvider(starknetChainId: .testnet, url: url)!
    }

    func testCall() async throws {
        let call = StarknetCall(
            contractAddress: Felt(fromHex: "0x5fa2c31b541653fc9db108f7d6857a1c2feda8e2abffbfa4ab4eaf1fcbfabd8")!,
            entrypoint: starknetSelector(from: "getPublicKey"),
            calldata: []
        )

        do {
            let result = try await provider.callContract(call)

            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0], Felt("0x738e76d6a8c3c66d9c9468276871dc6456b915ea2433a2a3bcd08ee15c39868"))
        } catch let e {
            print(e)
            throw e
        }
    }

    func testCallWithArguments() async throws {
        let call = StarknetCall(
            contractAddress: Felt(fromHex: "0x5fa2c31b541653fc9db108f7d6857a1c2feda8e2abffbfa4ab4eaf1fcbfabd8")!,
            entrypoint: starknetSelector(from: "supportsInterface"),
            calldata: [Felt(2138)]
        )

        let result = try await provider.callContract(call)

        XCTAssertEqual(result[0], Felt.zero)
    }

    func testGetNonce() async throws {
        let _ = try await provider.getNonce(of: "0x5fa2c31b541653fc9db108f7d6857a1c2feda8e2abffbfa4ab4eaf1fcbfabd8")
    }

    func testGetClassHash() async throws {
        let classHash = try await provider.getClassHashAt(erc20Address)

        print(classHash)
    }
}
