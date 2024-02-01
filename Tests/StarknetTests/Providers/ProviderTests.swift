import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
    static var devnetClient: DevnetClientProtocol!

    var provider: StarknetProviderProtocol!
    var signer: StarknetSignerProtocol!
    var account: StarknetAccountProtocol!
    var accountContractClassHash: Felt!
    var ethContractAddress: Felt!

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
        account = StarknetAccount(address: accountDetails.address, signer: signer, provider: provider, cairoVersion: .zero)
    }

    func makeStarknetProvider(url: String) -> StarknetProviderProtocol {
        StarknetProvider(url: url)!
    }

    func testRequestWithCustomURLSession() {
        let url = Self.devnetClient.rpcUrl
        let customURLSession = URLSession(configuration: .ephemeral)
        let starknetProvider = StarknetProvider(url: url, urlSession: customURLSession)

        XCTAssertNotNil(starknetProvider)
    }

    func testGetChainId() async throws {
        let chainId = try await provider.getChainId()

        XCTAssertEqual(chainId.toShortString(), "SN_GOERLI")
    }

    func testSpecVersion() async throws {
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
        let classHash = try await provider.getClassHashAt(ethContractAddress)

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

    func testGetInvokeTransactionByHash() async throws {
        let contract = try await Self.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])
        let transactionHash = try await Self.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "increase_balance", calldata: [2137]).transactionHash

        let result = try await provider.getTransactionBy(hash: transactionHash)
        XCTAssertTrue(result.type == .invoke)
    }

    func testGetDeployAccountTransactionByHash() async throws {
        let account = try await ProviderTests.devnetClient.deployAccount(name: "provider_test")

        let result = try await provider.getTransactionBy(hash: account.transactionHash)
        XCTAssertTrue(result.type == .deployAccount)
    }

    func testGetDeclareTransactionByHash() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let result = try await provider.getTransactionBy(hash: contract.declare.transactionHash)
        XCTAssertTrue(result.type == .declare)
    }

    func testGetTransactionStatus() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance")
        let status = try await provider.getTransactionStatusBy(hash: contract.declare.transactionHash)
        let status2 = try await provider.getTransactionStatusBy(hash: contract.deploy.transactionHash)

        XCTAssertEqual(status.finalityStatus, .acceptedL2)
        XCTAssertEqual(status2.finalityStatus, .acceptedL2)
    }

    func testGetInvokeTransactionReceipt() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])
        let transactionHash = try await ProviderTests.devnetClient.invokeContract(contractAddress: contract.deploy.contractAddress, function: "increase_balance", calldata: [2137]).transactionHash

        let receipt = try await provider.getTransactionReceiptBy(hash: transactionHash)
        XCTAssertTrue(receipt.isSuccessful)
    }

    func testGetDeployAccountTransactionReceipt() async throws {
        let account = try await ProviderTests.devnetClient.deployAccount(name: "provider_test")

        let receipt = try await provider.getTransactionReceiptBy(hash: account.transactionHash)
        XCTAssertTrue(receipt.isSuccessful)
    }

    func testGetDeclareTransactionReceipt() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let receipt = try await provider.getTransactionReceiptBy(hash: contract.declare.transactionHash)
        XCTAssertTrue(receipt.isSuccessful)
    }

    func testEstimateInvokeV1Fee() async throws {
        let contractAddress = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000]).deploy.contractAddress

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let call2 = StarknetCall(contractAddress: contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [100_000_000_000])

        let params1 = StarknetInvokeParamsV1(nonce: nonce, maxFee: 0)
        let tx1 = try await account.signV1(calls: [call], params: params1, forFeeEstimation: true)

        let params2 = StarknetInvokeParamsV1(nonce: Felt(nonce.value + 1)!, maxFee: 0)
        let tx2 = try await account.signV1(calls: [call, call2], params: params2, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: [tx1, tx2], simulationFlags: [])

        let tx1WithoutSignature = StarknetInvokeTransactionV1(senderAddress: tx1.senderAddress, calldata: tx1.calldata, signature: [], maxFee: tx1.maxFee, nonce: nonce, forFeeEstimation: true)
        let tx2WithoutSignature = StarknetInvokeTransactionV1(senderAddress: tx2.senderAddress, calldata: tx2.calldata, signature: [], maxFee: tx2.maxFee, nonce: Felt(nonce.value + 1)!, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: [tx1WithoutSignature, tx2WithoutSignature], simulationFlags: [.skipValidate])
    }

    func testEstimateInvokeV3Fee() async throws {
        let contractAddress = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000]).deploy.contractAddress
        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let call2 = StarknetCall(contractAddress: contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [100_000_000_000])

        let params1 = StarknetInvokeParamsV3(nonce: nonce, l1ResourceBounds: .zero)
        let tx1 = try await account.signV3(calls: [call], params: params1, forFeeEstimation: true)

        let params2 = StarknetInvokeParamsV3(nonce: Felt(nonce.value + 1)!, l1ResourceBounds: .zero)
        let tx2 = try await account.signV3(calls: [call, call2], params: params2, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: [tx1, tx2], simulationFlags: [])

        let tx1WithoutSignature = StarknetInvokeTransactionV3(senderAddress: tx1.senderAddress, calldata: tx1.calldata, signature: [], l1ResourceBounds: tx1.resourceBounds.l1Gas, nonce: nonce, forFeeEstimation: true)
        let tx2WithoutSignature = StarknetInvokeTransactionV3(senderAddress: tx2.senderAddress, calldata: tx2.calldata, signature: [], l1ResourceBounds: tx2.resourceBounds.l1Gas, nonce: Felt(nonce.value + 1)!, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: [tx1WithoutSignature, tx2WithoutSignature], simulationFlags: [.skipValidate])
    }

    func testEstimateDeployAccountV1Fee() async throws {
        let newSigner = StarkCurveSigner(privateKey: 1111)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let nonce = await (try? newAccount.getNonce()) ?? .zero

        let params = StarknetDeployAccountParamsV1(nonce: nonce, maxFee: .zero)

        let tx = try await newAccount.signDeployAccountV1(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: tx, simulationFlags: [])

        let txWithoutSignature = StarknetDeployAccountTransactionV1(signature: [], maxFee: tx.maxFee, nonce: tx.maxFee, contractAddressSalt: tx.contractAddressSalt, constructorCalldata: tx.constructorCalldata, classHash: tx.classHash, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: txWithoutSignature, simulationFlags: [.skipValidate])
    }

    func testEstimateDeployAccountV3Fee() async throws {
        let newSigner = StarkCurveSigner(privateKey: 3333)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let nonce = await (try? newAccount.getNonce()) ?? .zero

        let params = StarknetDeployAccountParamsV3(nonce: nonce, l1ResourceBounds: .zero)

        let tx = try await newAccount.signDeployAccountV3(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: tx)

        let txWithoutSignature = StarknetDeployAccountTransactionV3(signature: [], l1ResourceBounds: tx.resourceBounds.l1Gas, nonce: tx.nonce, contractAddressSalt: tx.contractAddressSalt, constructorCalldata: tx.constructorCalldata, classHash: tx.classHash, forFeeEstimation: true)

        let _ = try await provider.estimateFee(for: txWithoutSignature, simulationFlags: [.skipValidate])
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

        let feeEstimate = try await provider.estimateMessageFee(
            message,
            at: StarknetBlockId.tag(.pending)
        )

        XCTAssertNotEqual(Felt.zero, feeEstimate.gasPrice)
        XCTAssertNotEqual(Felt.zero, feeEstimate.gasConsumed)
        XCTAssertNotEqual(Felt.zero, feeEstimate.overallFee)
        XCTAssertEqual(feeEstimate.gasPrice.value * feeEstimate.gasConsumed.value, feeEstimate.overallFee.value)
    }

    func testSimulateTransactionsV1() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contract.deploy.contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])
        let params = StarknetInvokeParamsV1(nonce: nonce, maxFee: 500_000_000_000_000)

        let invokeTx = try await account.signV1(calls: [call], params: params, forFeeEstimation: false)

        let accountClassHash = try await provider.getClassHashAt(account.address)
        let newSigner = StarkCurveSigner(privateKey: 1001)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let newAccountParams = StarknetDeployAccountParamsV1(nonce: .zero, maxFee: 500_000_000_000_000)
        let deployAccountTx = try await newAccount.signDeployAccountV1(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero, params: newAccountParams, forFeeEstimation: false)

        let simulations = try await provider.simulateTransactions([invokeTx, deployAccountTx], at: .tag(.pending), simulationFlags: [])

        XCTAssertEqual(simulations.count, 2)
        XCTAssertTrue(simulations[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations[1].transactionTrace is StarknetDeployAccountTransactionTrace)

        let invokeWithoutSignature = StarknetInvokeTransactionV1(senderAddress: invokeTx.senderAddress, calldata: invokeTx.calldata, signature: [], maxFee: invokeTx.maxFee, nonce: invokeTx.nonce)

        let deployAccountWithoutSignature = StarknetDeployAccountTransactionV1(signature: [], maxFee: deployAccountTx.maxFee, nonce: deployAccountTx.nonce, contractAddressSalt: deployAccountTx.contractAddressSalt, constructorCalldata: deployAccountTx.constructorCalldata, classHash: deployAccountTx.classHash)

        let simulations2 = try await provider.simulateTransactions([invokeWithoutSignature, deployAccountWithoutSignature], at: .tag(.pending), simulationFlags: [.skipValidate])

        XCTAssertEqual(simulations2.count, 2)
        XCTAssertTrue(simulations2[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations2[1].transactionTrace is StarknetDeployAccountTransactionTrace)
    }

    func testSimulateTransactionsV3() async throws {
        let contract = try await ProviderTests.devnetClient.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])

        let nonce = try await account.getNonce()

        let call = StarknetCall(contractAddress: contract.deploy.contractAddress, entrypoint: starknetSelector(from: "increase_balance"), calldata: [1000])

        try await Self.devnetClient.prefundAccount(address: account.address, amount: 5_000_000_000_000_000_000, unit: .fri)
        let invokeL1Gas = StarknetResourceBounds(maxAmount: 500_000, maxPricePerUnit: 100_000_000_000)
        let params = StarknetInvokeParamsV3(nonce: nonce, l1ResourceBounds: invokeL1Gas)

        let invokeTx = try await account.signV3(calls: [call], params: params, forFeeEstimation: false)

        let accountClassHash = try await provider.getClassHashAt(account.address)
        let newSigner = StarkCurveSigner(privateKey: 3003)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress, amount: 5_000_000_000_000_000_000, unit: .fri)

        let deployAccountL1Gas = StarknetResourceBounds(maxAmount: 500_000, maxPricePerUnit: 100_000_000_000)
        let newAccountParams = StarknetDeployAccountParamsV3(nonce: 0, l1ResourceBounds: deployAccountL1Gas)
        let deployAccountTx = try await newAccount.signDeployAccountV3(classHash: accountClassHash, calldata: [newPublicKey], salt: .zero, params: newAccountParams, forFeeEstimation: false)

        let simulations = try await provider.simulateTransactions([invokeTx, deployAccountTx], at: .tag(.pending), simulationFlags: [])

        XCTAssertEqual(simulations.count, 2)
        XCTAssertTrue(simulations[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations[1].transactionTrace is StarknetDeployAccountTransactionTrace)

        let invokeWithoutSignature = StarknetInvokeTransactionV3(
            senderAddress: invokeTx.senderAddress,
            calldata: invokeTx.calldata,
            signature: [],
            l1ResourceBounds: invokeTx.resourceBounds.l1Gas,
            nonce: invokeTx.nonce
        )

        let deployAccountWithoutSignature = StarknetDeployAccountTransactionV3(
            signature: [],
            l1ResourceBounds: deployAccountTx.resourceBounds.l1Gas, nonce: deployAccountTx.nonce,
            contractAddressSalt: deployAccountTx.contractAddressSalt,
            constructorCalldata: deployAccountTx.constructorCalldata,
            classHash: deployAccountTx.classHash
        )

        let simulations2 = try await provider.simulateTransactions([invokeWithoutSignature, deployAccountWithoutSignature], at: .tag(.pending), simulationFlags: [.skipValidate])

        XCTAssertEqual(simulations2.count, 2)
        XCTAssertTrue(simulations2[0].transactionTrace is StarknetInvokeTransactionTrace)
        XCTAssertTrue(simulations2[1].transactionTrace is StarknetDeployAccountTransactionTrace)
    }
}
