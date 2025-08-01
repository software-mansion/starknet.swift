import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
    static var devnetClient: DevnetClientProtocol!

    var provider: StarknetProviderProtocol!
    var chainId: StarknetChainId!
    var signer: StarknetSignerProtocol!
    var account: StarknetAccountProtocol!
    var accountContractClassHash: Felt!
    var ethContractAddress: Felt!
    var resourceBounds: StarknetResourceBoundsMapping = .init(
        l1Gas: StarknetResourceBounds(
            maxAmount: UInt64AsHex(100_000_000_000),
            maxPricePerUnit: UInt128AsHex(10_000_000_000_000_000)
        ),
        l2Gas: StarknetResourceBounds(
            maxAmount: UInt64AsHex(100_000_000_000_000),
            maxPricePerUnit: UInt128AsHex(1_000_000_000_000_000_000)
        ),
        l1DataGas: StarknetResourceBounds(
            maxAmount: UInt64AsHex(100_000_000_000),
            maxPricePerUnit: UInt128AsHex(10_000_000_000_000_000)
        )
    )

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
        ethContractAddress = Self.devnetClient.constants.ethErc20ContractAddress
        accountContractClassHash = Self.devnetClient.constants.accountContractClassHash
        let accountDetails = Self.devnetClient.constants.predeployedAccount2
        signer = StarkCurveSigner(privateKey: accountDetails.privateKey)!

        chainId = try await provider.send(request: RequestBuilder.getChainId())
        account = StarknetAccount(address: accountDetails.address, signer: signer, provider: provider, chainId: chainId, cairoVersion: .one)
    }

    func makeStarknetProvider(url: String) -> StarknetProvider {
        StarknetProvider(url: url)!
    }

    func testRequestWithCustomURLSession() {
        let url = Self.devnetClient.rpcUrl
        let customURLSession = URLSession(configuration: .ephemeral)
        let starknetProvider = StarknetProvider(url: url, urlSession: customURLSession)

        XCTAssertNotNil(starknetProvider)
    }

    func testGetChainId() async throws {
        let chainId = try await provider.send(request: RequestBuilder.getChainId())

        XCTAssertEqual(chainId, .sepolia)
    }

    func testGetSpecVersion() async throws {
        let result = try await provider.send(request: RequestBuilder.getSpecVersion())

        XCTAssertFalse(result.isEmpty)
    }

    func testCall() async throws {
        let call = StarknetCall(
            contractAddress: ProviderTests.devnetClient.constants.predeployedAccount1.address,
            entrypoint: starknetSelector(from: "getPublicKey"),
            calldata: []
        )

        do {
            let result = try await provider.send(request: RequestBuilder.callContract(call))

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
            entrypoint: starknetSelector(from: "supports_interface"),
            calldata: [Felt(2138)]
        )

        let result = try await provider.send(request: RequestBuilder.callContract(call))

        XCTAssertEqual(result[0], Felt.zero)
    }

    func testGetNonce() async throws {
        let nonce = try await provider.send(request: RequestBuilder.getNonce(of: ProviderTests.devnetClient.constants.predeployedAccount1.address))

        print(nonce)
    }

    func testGetClassHash() async throws {
        let classHash = try await provider.send(request: RequestBuilder.getClassHashAt(ethContractAddress))

        print(classHash)
    }

    func testGetBlockNumber() async throws {
        let blockNumber = try await provider.send(request: RequestBuilder.getBlockNumber())

        print(blockNumber)
    }

    func testGetBlockHashAndNumber() async throws {
        // Note to future developers experiencing failures in this test:
        // If there were no transactions, minting or other changes to the state of the network,
        // "Block not found" error is likely to occur
        let result = try await provider.send(request: RequestBuilder.getBlockHashAndNumber())

        print(result)
    }

    func testGetEvents() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Events")
        let invokeResult = try await ProviderTests.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "emit_event", calldata: [1])

        try await ProviderTests.devnetClient.assertTransactionSucceeded(transactionHash: invokeResult.transactionHash)

        let filter = StarknetGetEventsFilter(
            fromBlockId: StarknetBlockId.number(0),
            toBlockId: StarknetBlockId.tag(.latest),
            address: contract.deploy.contractAddress,
            keys: [["0x477e157efde59c5531277ede78acb3e03ef69508c6c35fde3495aa0671d227"]],
            chunkSize: 10
        )
        let result = try await provider.send(request: RequestBuilder.getEvents(filter: filter))

        XCTAssertFalse(result.events.isEmpty)
        print(result)
    }

    func testGetTransactionByBlockIdAndHash() async throws {
        let result = try await provider.send(request: RequestBuilder.getTransactionBy(blockId: .tag(.latest), index: 0))

        print(result)
    }

    func testGetTransactionByHash() async throws {
        let previousResult = try await provider.send(request: RequestBuilder.getTransactionBy(blockId: .tag(.latest), index: 0))

        let _ = try await provider.send(request: RequestBuilder.getTransactionBy(hash: previousResult.transaction.hash!))

        do {
            let _ = try await provider.send(request: RequestBuilder.getTransactionBy(hash: "0x123"))
            XCTFail("Fetching transaction with nonexistent hash should fail")
        } catch {}
    }

    func testGetInvokeTransactionByHash() async throws {
        let contract = try await Self.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])
        let transactionHash = try await Self.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "increase_balance", calldata: [2137]).transactionHash

        let result = try await provider.send(request: RequestBuilder.getTransactionBy(hash: transactionHash))
        XCTAssertTrue(result.transaction.type == .invoke)
    }

    func testGetDeployAccountTransactionByHash() async throws {
        let account = try await ProviderTests.devnetClient.createDeployAccount()

        let result = try await provider.send(request: RequestBuilder.getTransactionBy(hash: account.transactionHash))
        XCTAssertTrue(result.transaction.type == .deployAccount)
    }

    func testGetDeclareTransactionByHash() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let result = try await provider.send(request: RequestBuilder.getTransactionBy(hash: contract.declare.transactionHash))
        XCTAssertTrue(result.transaction.type == .declare)
    }

    func testGetTransactionStatus() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [Felt(123)])
        let status = try await provider.send(request: RequestBuilder.getTransactionStatusBy(hash: contract.declare.transactionHash))
        let status2 = try await provider.send(request: RequestBuilder.getTransactionStatusBy(hash: contract.deploy.transactionHash))

        XCTAssertEqual(status.finalityStatus, .acceptedL2)
        XCTAssertEqual(status2.finalityStatus, .acceptedL2)
    }

    func testGetInvokeTransactionReceipt() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])
        let transactionHash = try await ProviderTests.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "increase_balance", calldata: [2137]).transactionHash

        let result = try await provider.send(request: RequestBuilder.getTransactionReceiptBy(hash: transactionHash))
        XCTAssertTrue(result.transactionReceipt.isSuccessful)
    }

    func testGetDeployAccountTransactionReceipt() async throws {
        let account = try await ProviderTests.devnetClient.createDeployAccount()

        let result = try await provider.send(request: RequestBuilder.getTransactionReceiptBy(hash: account.transactionHash))
        XCTAssertTrue(result.transactionReceipt.isSuccessful)
    }

    func testGetDeclareTransactionReceipt() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let result = try await provider.send(request: RequestBuilder.getTransactionReceiptBy(hash: contract.declare.transactionHash))
        XCTAssertTrue(result.transactionReceipt.isSuccessful)
    }

    func testEstimateInvokeV3Fee() async throws {
        let contractAddress = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000]).deploy.contractAddress
        let nonce = try await provider.send(request: account.getNonce())

        let call = StarknetCall(contractAddress: contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let call2 = StarknetCall(contractAddress: contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [100_000_000_000])

        let params1 = StarknetInvokeParamsV3(nonce: nonce, resourceBounds: StarknetResourceBoundsMapping.zero)
        let tx1 = try account.signV3(calls: [call], params: params1, forFeeEstimation: true)

        let params2 = StarknetInvokeParamsV3(nonce: Felt(nonce.value + 1)!, resourceBounds: StarknetResourceBoundsMapping.zero)
        let tx2 = try account.signV3(calls: [call, call2], params: params2, forFeeEstimation: true)

        let _ = try await provider.send(request: RequestBuilder.estimateFee(for: [tx1, tx2], simulationFlags: []))

        let tx1WithoutSignature = StarknetInvokeTransactionV3(senderAddress: tx1.senderAddress, calldata: tx1.calldata, signature: [], resourceBounds: tx1.resourceBounds, nonce: nonce, forFeeEstimation: true)
        let tx2WithoutSignature = StarknetInvokeTransactionV3(senderAddress: tx2.senderAddress, calldata: tx2.calldata, signature: [], resourceBounds: tx2.resourceBounds, nonce: Felt(nonce.value + 1)!, forFeeEstimation: true)

        let _ = try await provider.send(request: RequestBuilder.estimateFee(for: [tx1WithoutSignature, tx2WithoutSignature], simulationFlags: [.skipValidate]))
    }

    func testEstimateDeployAccountV3Fee() async throws {
        let newSigner = StarkCurveSigner(privateKey: 3333)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, chainId: chainId, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let nonce = await (try? provider.send(request: newAccount.getNonce())) ?? .zero

        let resourceBounds = StarknetResourceBoundsMapping.zero
        let params = StarknetDeployAccountParamsV3(nonce: nonce, resourceBounds: resourceBounds)

        let tx = try newAccount.signDeployAccountV3(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: true)

        let _ = try await provider.send(request: RequestBuilder.estimateFee(for: tx))

        let txWithoutSignature = StarknetDeployAccountTransactionV3(signature: [], resourceBounds: tx.resourceBounds, nonce: tx.nonce, contractAddressSalt: tx.contractAddressSalt, constructorCalldata: tx.constructorCalldata, classHash: tx.classHash, forFeeEstimation: true)

        let _ = try await provider.send(request: RequestBuilder.estimateFee(for: txWithoutSignature, simulationFlags: [.skipValidate]))
    }

    func testEstimateMessageFee() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "l1_l2")

        let l1Address: Felt = "0x8359E4B0152ed5A731162D3c7B0D8D56edB165A0"
        let user: Felt = .one

        let message = StarknetMessageFromL1(
            fromAddress: l1Address,
            toAddress: contract.deploy.contractAddress,
            entryPointSelector: starknetSelector(from: "deposit"),
            payload: [user, 1000]
        )

        let feeEstimate = try await provider.send(request: RequestBuilder.estimateMessageFee(
            message,
            at: StarknetBlockId.tag(.latest)
        ))
        XCTAssertNotEqual(UInt128AsHex.zero, feeEstimate.l1GasPrice)
        XCTAssertNotEqual(UInt128AsHex.zero, feeEstimate.l2GasPrice)
        XCTAssertNotEqual(UInt128AsHex.zero, feeEstimate.l1DataGasPrice)
        XCTAssertNotEqual(UInt64AsHex.zero.value, feeEstimate.l1GasConsumed.value + feeEstimate.l2GasConsumed.value + feeEstimate.l1DataGasConsumed.value)
        XCTAssertNotEqual(UInt128AsHex.zero, feeEstimate.overallFee)
        XCTAssertEqual(feeEstimate.l1GasPrice.value * feeEstimate.l1GasConsumed.value + feeEstimate.l2GasPrice.value * feeEstimate.l2GasConsumed.value + feeEstimate.l1DataGasPrice.value * feeEstimate.l1DataGasConsumed.value, feeEstimate.overallFee.value)
    }

    func testSimulateTransactionsV3() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let nonce = try await provider.send(request: account.getNonce())

        let call = StarknetCall(contractAddress: contract.deploy.contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])

        let params = StarknetInvokeParamsV3(nonce: nonce, resourceBounds: resourceBounds)

        let invokeTx = try account.signV3(calls: [call], params: params, forFeeEstimation: false)

        let accountClassHash = try await provider.send(request: RequestBuilder.getClassHashAt(account.address))
        let newSigner = StarkCurveSigner(privateKey: 3003)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, chainId: chainId, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress, amount: 10_000_000_000_000_000_000, unit: .fri)

        let resourceBounds: StarknetResourceBoundsMapping = .init(
            l1Gas: StarknetResourceBounds(
                maxAmount: UInt64AsHex(1000),
                maxPricePerUnit: UInt128AsHex(100_000_000_000)
            ),
            l2Gas: StarknetResourceBounds(
                maxAmount: UInt64AsHex(10_000_000),
                maxPricePerUnit: UInt128AsHex(100_000_000_000)
            ),
            l1DataGas: StarknetResourceBounds(
                maxAmount: UInt64AsHex(1000),
                maxPricePerUnit: UInt128AsHex(100_000_000_000)
            )
        )
        let newAccountParams = StarknetDeployAccountParamsV3(nonce: 0, resourceBounds: resourceBounds)
        let deployAccountTx = try newAccount.signDeployAccountV3(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero, params: newAccountParams, forFeeEstimation: false)

        let simulations = try await provider.send(request: RequestBuilder.simulateTransactions([invokeTx, deployAccountTx], at: .tag(.latest), simulationFlags: []))

        XCTAssertEqual(simulations.count, 2)
        XCTAssertTrue(simulations[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations[1].transactionTrace is StarknetDeployAccountTransactionTrace)

        let invokeWithoutSignature = StarknetInvokeTransactionV3(
            senderAddress: invokeTx.senderAddress,
            calldata: invokeTx.calldata,
            signature: [],
            resourceBounds: invokeTx.resourceBounds,
            nonce: invokeTx.nonce
        )

        let deployAccountWithoutSignature = StarknetDeployAccountTransactionV3(
            signature: [],
            resourceBounds: deployAccountTx.resourceBounds, nonce: deployAccountTx.nonce,
            contractAddressSalt: deployAccountTx.contractAddressSalt,
            constructorCalldata: deployAccountTx.constructorCalldata,
            classHash: deployAccountTx.classHash
        )

        let simulations2 = try await provider.send(request: RequestBuilder.simulateTransactions([invokeWithoutSignature, deployAccountWithoutSignature], at: .tag(.latest), simulationFlags: [.skipValidate]))

        XCTAssertEqual(simulations2.count, 2)
        XCTAssertTrue(simulations2[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations2[1].transactionTrace is StarknetDeployAccountTransactionTrace)
    }

    func testBatchGetTransactionByHash() async throws {
        let contract = try await Self.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])
        let transactionHash = try await Self.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "increase_balance", calldata: [2137]).transactionHash

        let invokeTx = try await provider.send(request: RequestBuilder.getTransactionBy(hash: transactionHash))

        let transactionsResponse = try await provider.send(requests:
            RequestBuilder.getTransactionBy(hash: invokeTx.transaction.hash!),
            RequestBuilder.getTransactionBy(hash: "0x123"))

        XCTAssertEqual(transactionsResponse.count, 2)
        XCTAssertEqual(try transactionsResponse[0].get().transaction.hash, invokeTx.transaction.hash!)

        do {
            let _ = try transactionsResponse[1].get().transaction.hash
            XCTFail("Fetching transaction with nonexistent hash should fail")
        } catch let error as StarknetProviderError {
            switch error {
            case let .jsonRpcError(_, message, _):
                XCTAssertEqual(message, "Transaction hash not found", "Unexpected error message received")
            default:
                XCTFail("Expected JsonRpcError but received \(error)")
            }
        } catch {
            XCTFail("Error was not a StarknetProviderError. Received error type: \(type(of: error))")
        }
    }

    func testGetBlockWithTxsWithLatestBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.latest))

        if case .preConfirmed = result {
            XCTFail("Expected .processed")
        }
    }

    func testGetBlockWithTxsWithPreConfirmedBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.preConfirmed))

        if case .processed = result {
            XCTFail("Expected .preConfirmed")
        }
    }
}
