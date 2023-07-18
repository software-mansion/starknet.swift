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
        super.setUp()
        devnetClient = makeDevnetClient()
    }

    override class func tearDown() {
        super.tearDown()
        devnetClient.close()
    }

    override func setUp() async throws {
        try await super.setUp()

        if !Self.devnetClient.isRunning() {
            try await Self.devnetClient.start()
        }

        provider = makeStarknetProvider(url: Self.devnetClient.rpcUrl)
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

    func testGetBlockNumber() async throws {
        let blockNumber = try await provider.getBlockNumber()

        print(blockNumber)
    }

    func testGetBlockHashAndNumber() async throws {
        let result = try await provider.getBlockHashAndNumber()

        print(result)
    }

    func testGetEvents() async throws {
        let acc = try await ProviderTests.devnetClient.deployAccount(name: "test_events")
        let contract = try await ProviderTests.devnetClient.deployContract(contractName: "events", deprecated: true)
        let sigerProtocol = StarkCurveSigner(privateKey: acc.details.privateKey)
        let account = StarknetAccount(address: acc.details.address, signer: sigerProtocol!, provider: provider, cairoVersion: .zero)
        let call = StarknetCall(contractAddress: contract.address, entrypoint: starknetSelector(from: "increase_balance"), calldata: [2137])
        let _ = try await account.execute(call: call)

        let filter = StarknetGetEventsFilter(address: contract.address, keys: [["0x03db3da4221c078e78bd987e54e1cc24570d89a7002cefa33e548d6c72c73f9d"]])
        let result = try await provider.getEvents(filter: filter)

        print(result)
    }

    func testGetTransactionByBlockIdAndHash() async throws {
        let result = try await provider.getTransactionBy(blockId: .tag(.latest), index: 0)

        print(result)
    }

    func testGetTransactionByHash() async throws {
        let previousResult = try await provider.getTransactionBy(blockId: .tag(.latest), index: 0)

        let _ = try await provider.getTransactionBy(hash: previousResult.hash)

        do {
            let _ = try await provider.getTransactionBy(hash: "0x123")
            XCTFail("Fetching transaction with nonexistent hash should fail")
        } catch {}
    }

    func testGetTransactionReceipt() async throws {
        let acc = try await ProviderTests.devnetClient.deployAccount(name: "test_receipt")
        let contract = try await ProviderTests.devnetClient.deployContract(contractName: "events", deprecated: true)
        let sigerProtocol = StarkCurveSigner(privateKey: acc.details.privateKey)
        let account = StarknetAccount(address: acc.details.address, signer: sigerProtocol!, provider: provider, cairoVersion: .zero)
        let call = StarknetCall(contractAddress: contract.address, entrypoint: starknetSelector(from: "increase_balance"), calldata: [2137])
        let invoke = try await account.execute(call: call)

        let resAccDeploy = try await provider.getTransactionReceiptBy(hash: acc.txHash)
        let resInvoke = try await provider.getTransactionReceiptBy(hash: invoke.transactionHash)
    }

    func testEstimateFee() async throws {
        let acc = try await ProviderTests.devnetClient.deployAccount(name: "test_estimate_fee")
        let contract = try await ProviderTests.devnetClient.deployContract(contractName: "balance", deprecated: true)
        let signer = StarkCurveSigner(privateKey: acc.details.privateKey)!
        let account = StarknetAccount(address: acc.details.address, signer: signer, provider: provider, cairoVersion: .zero)

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contract.address, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let call2 = StarknetCall(contractAddress: contract.address, entrypoint: starknetSelector(from: "increase_balance"), calldata: [100_000_000_000])

        let params1 = StarknetExecutionParams(nonce: nonce, maxFee: 0)
        let tx1 = try account.sign(calls: [call], params: params1, forFeeEstimation: true)

        let params2 = StarknetExecutionParams(nonce: Felt(nonce.value + 1)!, maxFee: 0)
        let tx2 = try account.sign(calls: [call, call2], params: params2, forFeeEstimation: true)

        let fees = try await provider.estimateFee(for: [tx1, tx2])

        XCTAssertEqual(fees.count, 2)
    }

    func testSimulateTransactions() async throws {
        let acc = try await ProviderTests.devnetClient.deployAccount(name: "test_simulate_transactions")
        let signer = StarkCurveSigner(privateKey: acc.details.privateKey)!
        let contract = try await ProviderTests.devnetClient.deployContract(contractName: "balance", deprecated: true)
        let account = StarknetAccount(address: acc.details.address, signer: signer, provider: provider, cairoVersion: .zero)

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contract.address, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let params = StarknetExecutionParams(nonce: nonce, maxFee: 1_000_000_000_000)

        let invokeTx = try account.sign(calls: [call], params: params, forFeeEstimation: true)

        let accountClassHash = try await provider.getClassHashAt(account.address)
        let newSigner = StarkCurveSigner(privateKey: 1234)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let newAccountParams = StarknetExecutionParams(nonce: 0, maxFee: 0)
        let deployAccountTx = try newAccount.signDeployAccount(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero, params: newAccountParams, forFeeEstimation: true)

        let simulations = try await provider.simulateTransactions([invokeTx, deployAccountTx], at: .tag(.latest), simulationFlags: [])

        XCTAssertEqual(simulations.count, 2)
        XCTAssertTrue(simulations[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations[1].transactionTrace is StarknetDeployAccountTransactionTrace)

        let invokeWithoutSignature = StarknetSequencerInvokeTransaction(
            senderAddress: invokeTx.senderAddress,
            calldata: invokeTx.calldata,
            signature: [],
            maxFee: invokeTx.maxFee,
            nonce: invokeTx.nonce,
            version: invokeTx.version
        )

        let deployAccountWithoutSignature = StarknetSequencerDeployAccountTransaction(
            signature: [],
            maxFee: deployAccountTx.maxFee,
            nonce: deployAccountTx.nonce,
            contractAddressSalt: deployAccountTx.contractAddressSalt,
            constructorCalldata: deployAccountTx.constructorCalldata,
            classHash: deployAccountTx.classHash,
            version: deployAccountTx.version
        )

        let simulations2 = try await provider.simulateTransactions([invokeWithoutSignature, deployAccountWithoutSignature], at: .tag(.latest), simulationFlags: [.skipValidate])

        XCTAssertEqual(simulations2.count, 2)
        XCTAssertTrue(simulations2[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations2[1].transactionTrace is StarknetDeployAccountTransactionTrace)
    }
}
