import XCTest

@testable import Starknet

let erc20Address: Felt = "0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7"

final class AccountTests: XCTestCase {
    static var devnetClient: DevnetClientProtocol!

    var provider: StarknetProviderProtocol!
    var signer: StarknetSignerProtocol!
    var account: StarknetAccountProtocol!
    var accountContractClassHash: Felt!

    override func setUp() async throws {
        try await super.setUp()

        if !Self.devnetClient.isRunning() {
            try await Self.devnetClient.start()
        }

        provider = StarknetProvider(starknetChainId: .testnet, url: Self.devnetClient.rpcUrl)!
        accountContractClassHash = AccountTests.devnetClient.constants.accountContractClassHash
        let accountDetails = AccountTests.devnetClient.constants.predeployedAccount1
        signer = StarkCurveSigner(privateKey: accountDetails.privateKey)!
        account = StarknetAccount(address: accountDetails.address, signer: signer, provider: provider, cairoVersion: .zero)
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

        let call = StarknetCall(contractAddress: erc20Address, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let result = try await account.execute(call: call)

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testExecuteCustomParams() async throws {
        let recipientAddress = AccountTests.devnetClient.constants.predeployedAccount2.address

        let calldata: [Felt] = [
            recipientAddress,
            1000,
            0,
        ]

        let call = StarknetCall(contractAddress: erc20Address, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)

        let nonce = try await account.getNonce()
        let feeEstimate = try await account.estimateFee(call: call, nonce: nonce)
        let maxFee = estimatedFeeToMaxFee(feeEstimate.overallFee)

        let params = StarknetOptionalExecutionParams(nonce: nonce, maxFee: maxFee)

        let result = try await account.execute(call: call, params: params)

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

        let call1 = StarknetCall(contractAddress: AccountTests.devnetClient.constants.erc20ContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata1)
        let call2 = StarknetCall(contractAddress: AccountTests.devnetClient.constants.erc20ContractAddress, entrypoint: starknetSelector(from: "transfer"), calldata: calldata2)

        let result = try await account.execute(calls: [call1, call2])

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: result.transactionHash)
    }

    func testDeployAccount() async throws {
        let newSigner = StarkCurveSigner(privateKey: 1234)!
        let newPublicKey = newSigner.publicKey
        let newAccountAddress = StarknetContractAddressCalculator.calculateFrom(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero)
        let newAccount = StarknetAccount(address: newAccountAddress, signer: newSigner, provider: provider, cairoVersion: .zero)

        try await Self.devnetClient.prefundAccount(address: newAccountAddress)

        let nonce = await (try? newAccount.getNonce()) ?? .zero

        let feeEstimate = try await newAccount.estimateDeployAccountFee(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, nonce: nonce)
        let maxFee = estimatedFeeToMaxFee(feeEstimate.overallFee)

        let params = StarknetExecutionParams(nonce: nonce, maxFee: maxFee)

        let deployAccountTransaction = try newAccount.signDeployAccount(classHash: accountContractClassHash, calldata: [newPublicKey], salt: .zero, params: params, forFeeEstimation: false)

        let response = try await provider.addDeployAccountTransaction(deployAccountTransaction)

        try await Self.devnetClient.assertTransactionSucceeded(transactionHash: response.transactionHash)

        let newNonce = try await newAccount.getNonce()

        XCTAssertEqual(newNonce.value - nonce.value, Felt.one.value)
    }

    func testSignTypedData() async throws {
        let typedData = loadTypedDataFromFile(name: "typed_data_struct_array_example")!

        let signature = try account.sign(typedData: typedData)
        XCTAssertTrue(signature.count > 0)

        let successResult = try await account.verify(signature: signature, for: typedData)
        XCTAssertTrue(successResult)

        let failResult = try await account.verify(signature: [.one, .one], for: typedData)
        XCTAssertFalse(failResult)
    }
}
