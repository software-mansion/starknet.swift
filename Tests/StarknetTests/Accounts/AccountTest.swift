import XCTest

@testable import Starknet

final class AccountTests: XCTestCase {
    static var devnetClient: DevnetClientProtocol!

    var provider: StarknetProviderProtocol!
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
        account = StarknetAccount(address: accountDetails.address, signer: signer, provider: provider, cairoVersion: .zero)
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

    func testExecute() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let result = try await account.executeV1(call: call)

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

        let result = try await account.executeV3(calls: [call])

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteCustomParams() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: ethContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let nonce = try await account.getNonce()
        let feeEstimate = try await account.estimateFeeV1(call: call, nonce: nonce)
        let maxFee = feeEstimate.toMaxFee()

        let params = StarknetOptionalInvokeParamsV1(nonce: nonce, maxFee: maxFee)

        let result = try await account.executeV1(call: call, params: params)

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

        let nonce = try await account.getNonce()
        let feeEstimate = try await account.estimateFeeV3(call: call, nonce: nonce, skipValidate: false)
        let resourceBounds = feeEstimate.toResourceBounds()

        let params = StarknetOptionalInvokeParamsV3(nonce: nonce, l1ResourceBounds: resourceBounds.l1Gas)

        let result = try await account.executeV3(calls: [call], params: params)

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteMultipleCalls() async throws {
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

        let result = try await account.executeV1(calls: [call1, call2])

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testDeployAccount() async throws {
        let newSigner = StarkCurveSigner(privateKey: 1234)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let nonce = await (try? newAccount.getNonce()) ?? .zero

        let feeEstimate = try await newAccount.estimateDeployAccountFeeV1(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, nonce: nonce, skipValidate: false)
        let maxFee = feeEstimate.toMaxFee()

        let params = StarknetDeployAccountParamsV1(nonce: nonce, maxFee: maxFee)

        let deployAccountTransaction = try await newAccount.signDeployAccountV1(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: false)

        let response = try await provider.addDeployAccountTransaction(deployAccountTransaction)

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: response.transactionHash)

        let newNonce = try await newAccount.getNonce()

        XCTAssertEqual(newNonce.value - nonce.value, Felt.one.value)
    }

    func testDeployAccountV3() async throws {
        let newSigner = StarkCurveSigner(privateKey: 4567)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress, unit: .fri)

        let nonce = await (try? newAccount.getNonce()) ?? .zero

        let feeEstimate = try await newAccount.estimateDeployAccountFeeV3(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, nonce: nonce)

        let params = StarknetDeployAccountParamsV3(nonce: nonce, l1ResourceBounds: feeEstimate.toResourceBounds().l1Gas)

        let deployAccountTransaction = try await newAccount.signDeployAccountV3(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: false)

        let response = try await provider.addDeployAccountTransaction(deployAccountTransaction)

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: response.transactionHash)

        let newNonce = try await newAccount.getNonce()

        XCTAssertEqual(newNonce.value - nonce.value, Felt.one.value)
    }

    func testSignTypedData() async throws {
        let typedData = loadTypedDataFromFile(name: "typed_data_struct_array_example")!

        let signature = try await account.sign(typedData: typedData)
        XCTAssertTrue(signature.count > 0)

        let successResult = try await account.verify(signature: signature, for: typedData)
        XCTAssertTrue(successResult)

        let failResult = try await account.verify(signature: [.one, .one], for: typedData)
        XCTAssertFalse(failResult)
    }
}
