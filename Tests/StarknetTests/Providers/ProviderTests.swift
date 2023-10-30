import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
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

    // TODO: (#89): Re-enable once devnet-rs supports RPC 0.5.0
    func disabledTestSpecVersion() async throws {
        let result = try await provider.specVersion()
        XCTAssertFalse(result.isEmpty)
    }

    func testCall() async throws {
        let call = StarknetCall(
            contractAddress: ProviderTests.devnetClient.constants.predeployedAccount1.address,
            entrypoint: starknetSelector(from: "getPublicKey"),
            calldata: []
        )

        do {
            let result = try await provider.callContract(call)

            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0], ProviderTests.devnetClient.constants.predeployedAccount1.publicKey)
        } catch let e {
            print(e)
            throw e
        }
    }

    func testCallWithArguments() async throws {
        let call = StarknetCall(
            contractAddress: ProviderTests.devnetClient.constants.predeployedAccount1.address,
            entrypoint: starknetSelector(from: "supportsInterface"),
            calldata: [Felt(2138)]
        )

        let result = try await provider.callContract(call)

        XCTAssertEqual(result[0], Felt.zero)
    }

    func testGetNonce() async throws {
        let nonce = try await provider.getNonce(of: ProviderTests.devnetClient.constants.predeployedAccount1.address)

        print(nonce)
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
        // Note to future developers experiencing failures in this test:
        // If there were no transactions, minting or other changes to the state of the network,
        // "Block not found" error is likely to occur
        let result = try await provider.getBlockHashAndNumber()

        print(result)
    }

    func testGetEvents() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Events")
        let invokeResult = try await ProviderTests.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "emit_event", calldata: [1])

        try await ProviderTests.devnetClient.assertTransactionSucceeded(transactionHash: invokeResult.transactionHash)

        let filter = StarknetGetEventsFilter(address: contract.deploy.contractAddress, keys: [["0x477e157efde59c5531277ede78acb3e03ef69508c6c35fde3495aa0671d227"]])
        let result = try await provider.getEvents(filter: filter)

        XCTAssertFalse(result.events.isEmpty)
        print(result)
    }

    func testGetTransactionByBlockIdAndHash() async throws {
        let result = try await provider.getTransactionBy(blockId: .tag(.latest), index: 0)

        print(result)
    }

    func testGetTransactionByHash() async throws {
        let previousResult = try await provider.getTransactionBy(blockId: .tag(.latest), index: 0)

        let _ = try await provider.getTransactionBy(hash: previousResult.hash!)

        do {
            let _ = try await provider.getTransactionBy(hash: "0x123")
            XCTFail("Fetching transaction with nonexistent hash should fail")
        } catch {}
    }

    // TODO: (#89) Re-enable once devnet-rs supports RPC 0.5.0
    func disabledTestGetTransactionStatus() async throws {
        let deployedContract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance")
        let status = try await provider.getTransactionStatusBy(hash: deployedContract.declare.transactionHash)
        let status2 = try await provider.getTransactionStatusBy(hash: deployedContract.deploy.transactionHash)

        XCTAssertEqual(status.finalityStatus, .acceptedL2)
        XCTAssertEqual(status2.finalityStatus, .acceptedL2)
    }

    // TODO: (#89) Re-enable once devnet-rs supports RPC 0.5.0
    func disabledTestGetTransactionReceipt() async throws {
        let accountName = "test_receipt"
        let _ = try await ProviderTests.devnetClient.createAccount(name: accountName)
        let acc = try await ProviderTests.devnetClient.deployAccount(name: accountName)
        let acc2 = try await ProviderTests.devnetClient.deployAccount(name: accountName)

        let deployedContract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance")
        let invokeTransaction = try await ProviderTests.devnetClient.invokeContract(contractAddress: deployedContract.deploy.contractAddress, function: "increase_balance", calldata: [2137])

        let declareReceipt = try await provider.getTransactionReceiptBy(hash: deployedContract.declare.transactionHash)
        XCTAssertTrue(declareReceipt.isSuccessful)

        let deployReceipt = try await provider.getTransactionReceiptBy(hash: deployedContract.deploy.transactionHash)
        XCTAssertTrue(deployReceipt.isSuccessful)

        let invokeReceipt = try await provider.getTransactionReceiptBy(hash: invokeTransaction.transactionHash)
        XCTAssertTrue(invokeReceipt.isSuccessful)

        let deployAccountReceipt = try await provider.getTransactionReceiptBy(hash: acc.transactionHash)
        XCTAssertTrue(deployAccountReceipt.isSuccessful)

        let deployAccountReceipt2 = try await provider.getTransactionReceiptBy(hash: acc2.transactionHash)
        XCTAssertFalse(deployAccountReceipt2.isSuccessful)
        XCTAssertNotNil(deployAccountReceipt2.revertReason)
    }

    // TODO: (#100) separate estimateFee tests based on transaction type
    func testEstimateFee() async throws {
        let acc = try await ProviderTests.devnetClient.createDeployAccount(name: "test_estimate_fee")
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance")

        let signer = StarkCurveSigner(privateKey: acc.details.privateKey)!
        let account = StarknetAccount(address: acc.details.address, signer: signer, provider: provider, cairoVersion: .zero)

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contract.deploy.contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let call2 = StarknetCall(contractAddress: contract.deploy.contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [100_000_000_000])

        let params1 = StarknetExecutionParams(nonce: nonce, maxFee: 0)
        let tx1 = try account.sign(calls: [call], params: params1, forFeeEstimation: true)

        let params2 = StarknetExecutionParams(nonce: Felt(nonce.value + 1)!, maxFee: 0)
        let tx2 = try account.sign(calls: [call, call2], params: params2, forFeeEstimation: true)

        let fees = try await provider.estimateFee(for: [tx1, tx2])

        XCTAssertEqual(fees.count, 2)
    }

    func testEstimateMessageFee() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance")

        let message = StarknetMessageFromL1(
            fromAddress: "0xbe1259ff905cadbbaa62514388b71bdefb8aacc1",
            toAddress: contract.deploy.contractAddress,
            entryPointSelector: starknetSelector(from: "increase_balance"),
            payload: [
                "0x54d01e5fc6eb4e919ceaab6ab6af192e89d1beb4f29d916768c61a4d48e6c95",
                "0x38d7ea4c68000",
                0,
            ]
        )

        let feeEstimate = try await provider.estimateMessageFee(
            message,
            at: StarknetBlockId.tag(.latest)
        )

        XCTAssertNotEqual(Felt.zero, feeEstimate.gasPrice)
        XCTAssertNotEqual(Felt.zero, feeEstimate.gasConsumed)
        XCTAssertNotEqual(Felt.zero, feeEstimate.overallFee)
        XCTAssertEqual(feeEstimate.gasPrice.value * feeEstimate.gasConsumed.value, feeEstimate.overallFee.value)
    }

    // TODO: Re-enable when devnet-rs supports RPC 0.5.0
    func disabledTestSimulateTransactions() async throws {
        XCTAssertTrue(false)

        let acc = try await ProviderTests.devnetClient.createDeployAccount(name: "test_simulate_transactions")
        let signer = StarkCurveSigner(privateKey: acc.details.privateKey)!
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance")
        let account = StarknetAccount(address: acc.details.address, signer: signer, provider: provider, cairoVersion: .zero)

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contract.deploy.contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
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
            nonce: invokeTx.nonce
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
