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

        provider = StarknetProvider(url: Self.devnetClient.rpcUrl)!
        let accountDetails = ExecutionTests.devnetClient.constants.predeployedAccount1
        signer = StarkCurveSigner(privateKey: accountDetails.privateKey)!
        let chainId = try await provider.send(request: RequestBuilder.getChainId())
        account = StarknetAccount(address: accountDetails.address, signer: signer, provider: provider, chainId: chainId, cairoVersion: .one)
        balanceContractAddress = try await Self.devnetClient.declareDeployContract(contractName: "Balance").deploy.contractAddress
    }

    override class func setUp() {
        super.setUp()
        devnetClient = makeDevnetClient()
    }

    override class func tearDown() {
        super.tearDown()

        if let devnetClient {
            devnetClient.close()
        }
    }

    func testStarknetCallsToExecuteCalldataCairo1() async throws {
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
        let params = StarknetInvokeParamsV1(nonce: .zero, maxFee: .zero)

        let signedTx = try account.signV1(calls: [call1, call2, call3], params: params)
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

        let signedEmptyTx = try account.signV1(calls: [], params: params)

        XCTAssertEqual([.zero], signedEmptyTx.calldata)
    }
}
