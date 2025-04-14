import XCTest

@testable import Starknet

@available(macOS 15.0, *)
final class AccountTests: XCTestCase {
    static var devnetClient: DevnetClientProtocol!

    var provider: StarknetProviderProtocol!
    var chainId: StarknetChainId!
    var signer: StarknetSignerProtocol!
    var account: StarknetAccountProtocol!
    var accountContractClassHash: Felt!
    var ethContractAddress: Felt!

    override func setUp() async throws {
        try await super.setUp()

        if !Self.devnetClient.isRunning() {
            try await Self.devnetClient.start()
        }

        provider = StarknetProvider(url: Self.devnetClient.rpcUrl)!
        accountContractClassHash = Self.devnetClient.constants.accountContractClassHash
        ethContractAddress = Self.devnetClient.constants.ethErc20ContractAddress
        let accountDetails = Self.devnetClient.constants.predeployedAccount1
        signer = StarkCurveSigner(privateKey: accountDetails.privateKey)!
        chainId = try await provider.send(request: RequestBuilder.getChainId())
        account = StarknetAccount(address: accountDetails.address, signer: signer, provider: provider, chainId: chainId, cairoVersion: .one)
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

    func testGetNonce() async throws {
        let _ = try await account.getNonce()
    }

    func testExecuteV1() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let result = try await provider.send(request: account.executeV1(call: call))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteV3() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let result = try await provider.send(request: account.executeV3(calls: [call]))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteV1FeeMultiplier() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [recipientAddress, 1000, 0]
        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let result = try await provider.send(request: account.executeV1(call: call, estimateFeeMultiplier: 1.8))
        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)

        let result2 = try await provider.send(request: account.executeV1(call: call, estimateFeeMultiplier: 0.9))
        try await Self.devnetClient.assertTransactionFailed(transactionHash: result2.transactionHash)
    }

    func testExecuteV3FeeMultipliers() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [recipientAddress, 1000, 0]
        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let result = try await provider.send(request: account.executeV3(call: call, estimateAmountMultiplier: 1.8, estimateUnitPriceMultiplier: 1.8))
        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)

        let result2 = try await provider.send(request: account.executeV3(call: call, estimateAmountMultiplier: 0.9, estimateUnitPriceMultiplier: 1.0))
        try await Self.devnetClient.assertTransactionFailed(transactionHash: result2.transactionHash)
    }

    func testExecuteV1CustomParams() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let nonce = try await provider.send(request: account.getNonce())
        let feeEstimate = try await provider.send(request: account.estimateFeeV1(call: call, nonce: nonce))[0]
        let maxFee = feeEstimate.toMaxFee()

        let params = StarknetOptionalInvokeParamsV1(nonce: nonce, maxFee: maxFee)

        let result = try await provider.send(request: account.executeV1(call: call, params: params))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteV3CustomParams() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let nonce = try await provider.send(request: account.getNonce())
        let feeEstimate = try await provider.send(request: account.estimateFeeV3(call: call, nonce: nonce, skipValidate: false))[0]
        let resourceBounds = feeEstimate.toResourceBounds()

        let params = StarknetOptionalInvokeParamsV3(nonce: nonce, resourceBounds: resourceBounds)

        let result = try await provider.send(request: account.executeV3(calls: [call], params: params))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteV1MultipleCalls() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata1: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let calldata2: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call1 = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata1)
        let call2 = StarknetCall(contractAddress: AccountTests.devnetClient.constants.ethErc20ContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata2)

        let result = try await provider.send(request: account.executeV1(calls: [call1, call2]))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testDeployAccountV1() async throws {
        let newSigner = StarkCurveSigner(privateKey: 1234)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, chainId: chainId, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let nonce = await (try? provider.send(request: newAccount.getNonce())) ?? .zero

        let feeEstimate = try await provider.send(request: newAccount.estimateDeployAccountFeeV1(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, nonce: nonce, skipValidate: false))[0]
        let maxFee = feeEstimate.toMaxFee()

        let params = StarknetDeployAccountParamsV1(nonce: nonce, maxFee: maxFee)

        let deployAccountTransaction = try newAccount.signDeployAccountV1(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: false)

        let response = try await provider.send(request: RequestBuilder.addDeployAccountTransaction(deployAccountTransaction))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: response.transactionHash)

        let newNonce = try await provider.send(request: newAccount.getNonce())

        XCTAssertEqual(newNonce.value - nonce.value, Felt.one.value)
    }

    func testDeployAccountV3() async throws {
        let newSigner = StarkCurveSigner(privateKey: 4567)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, chainId: chainId, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress, unit: .fri)

        let nonce = await (try? provider.send(request: newAccount.getNonce())) ?? .zero

        let feeEstimate = try await provider.send(request: newAccount.estimateDeployAccountFeeV3(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, nonce: nonce))[0]

        let params = StarknetDeployAccountParamsV3(nonce: nonce, resourceBounds: feeEstimate.toResourceBounds())

        let deployAccountTransaction = try newAccount.signDeployAccountV3(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: false)

        let response = try await provider.send(request: RequestBuilder.addDeployAccountTransaction(deployAccountTransaction))

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: response.transactionHash)

        let newNonce = try await provider.send(request: newAccount.getNonce())

        XCTAssertEqual(newNonce.value - nonce.value, Felt.one.value)
    }

    func testSignTypedDataRev0() async throws {
        let typedData = try loadTypedDataFromFile(name: "typed_data_rev_0_struct_array_example")

        let signature = try account.sign(typedData: typedData)
        XCTAssertTrue(signature.count > 0)

        let successResult = try await account.verify(signature: signature, for: typedData)
        XCTAssertTrue(successResult)

        let failResult = try await account.verify(signature: [.one, .one], for: typedData)
        XCTAssertFalse(failResult)
    }

    func testSignTypedDataRev1() async throws {
        let typedData = try loadTypedDataFromFile(name: "typed_data_rev_1_example")

        let signature = try account.sign(typedData: typedData)
        XCTAssertTrue(signature.count > 0)

        let successResult = try await account.verify(signature: signature, for: typedData)
        XCTAssertTrue(successResult)

        let failResult = try await account.verify(signature: [.one, .one], for: typedData)
        XCTAssertFalse(failResult)
    }
}
