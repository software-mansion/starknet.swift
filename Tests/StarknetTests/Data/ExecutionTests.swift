import XCTest

@testable import Starknet

final class ExecutionTests: XCTestCase {
    static var devnetClient: DevnetClientProtocol!

    var provider: StarknetProviderProtocol!
    var signer: StarknetSignerProtocol!
    var account: StarknetAccountProtocol!
    var balanceContractAddress: Felt!

    override func setUp() async throws {
        try await super.setUp()

        if !Self.devnetClient.isRunning() {
            try await Self.devnetClient.start()
        }

        provider = StarknetProvider(starknetChainId: .testnet, url: Self.devnetClient.rpcUrl)!
        signer = StarkCurveSigner(privateKey: "0x5421eb02ce8a5a972addcd89daefd93c")!
        account = StarknetAccount(address: "0x5fa2c31b541653fc9db108f7d6857a1c2feda8e2abffbfa4ab4eaf1fcbfabd8", signer: signer, provider: provider, cairoVersion: .one)
        balanceContractAddress = try await Self.devnetClient.deployContract(contractName: "balance", deprecated: true).address
    }

    override class func setUp() {
        super.setUp()
        devnetClient = makeDevnetClient()
    }

    override class func tearDown() {
        super.tearDown()

        if let devnetClient = Self.devnetClient {
            devnetClient.close()
        }
    }

    func testStarknetCallsToExecuteCalldataCairo1() throws {
        let call1 = StarknetCall(
            contractAddress: balanceContractAddress,
            entrypoint: starknetSelector(from: "increase_balance"),
            calldata: [Felt(10), Felt(20), Felt(30)]
        )

        let call2 = StarknetCall(
            contractAddress: Felt(999),
            entrypoint: starknetSelector(from: "empty_calldata"),
            calldata: []
        )

        let call3 = StarknetCall(
            contractAddress: Felt(123),
            entrypoint: starknetSelector(from: "another_method"),
            calldata: [Felt(100), Felt(200)]
        )
        let params = StarknetExecutionParams(nonce: .zero, maxFee: .zero)

        let signedTx = try account.sign(calls: [call1, call2, call3], params: params)
        let expectedCalldata = [
            Felt(3),
            balanceContractAddress,
            starknetSelector(from: "increase_balance"),
            Felt(3),
            Felt(10),
            Felt(20),
            Felt(30),
            Felt(999),
            starknetSelector(from: "empty_calldata"),
            Felt(0),
            Felt(123),
            starknetSelector(from: "another_method"),
            Felt(2),
            Felt(100),
            Felt(200),
        ]

        XCTAssertEqual(expectedCalldata, signedTx.calldata)

        let signedEmptyTx = try account.sign(calls: [], params: params)

        XCTAssertEqual([.zero], signedEmptyTx.calldata)
    }
}
