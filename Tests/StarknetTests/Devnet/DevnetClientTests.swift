@testable import Starknet
import XCTest

final class DevnetClientTests: XCTestCase {
    var client: DevnetClientProtocol!

    override func setUp() async throws {
        client = makeDevnetClient()
        try await client.start()
    }

    override func tearDown() async throws {
        client.close()
    }

    // TODO: (#130) re-enable once creating accounts is supported again
    func disabledTestCreateDeployAccount() async throws {
        let resourceBounds = StarknetResourceBoundsMapping(
            l1Gas: StarknetResourceBounds(
                maxAmount: 100_000,
                maxPricePerUnit: 10_000_000_000_000
            ),
            l2Gas: StarknetResourceBounds(
                maxAmount: 1_000_000_000,
                maxPricePerUnit: 100_000_000_000_000_000
            ),
            l1DataGas: StarknetResourceBounds(
                maxAmount: 100_000,
                maxPricePerUnit: 10_000_000_000_000
            )
        )

        let account = try await client.createDeployAccount(name: "Account1")
        try await client.assertTransactionSucceeded(transactionHash: account.transactionHash)

        let account2 = try await client.createDeployAccount()
        try await client.assertTransactionSucceeded(transactionHash: account2.transactionHash)
    }

    // TODO: (#130) re-enable once creating accounts is supported again
    func disabledTestCreateAndDeployAccount() async throws {
        let account = try await client.createAccount()
        try await client.prefundAccount(address: account.details.address)
        let deployedAccount = try await client.deployAccount(name: account.name)
        try await client.assertTransactionSucceeded(transactionHash: deployedAccount.transactionHash)
    }

    func testDeclareDeploy() async throws {
        let contract = try await client.declareDeployContract(contractName: "Balance", constructorCalldata: [1000])
        try await client.assertTransactionSucceeded(transactionHash: contract.declare.transactionHash)
        try await client.assertTransactionSucceeded(transactionHash: contract.deploy.transactionHash)
    }

    func testDeclareAndDeploy() async throws {
        let declaredContract = try await client.declareContract(contractName: "Events")
        try await client.assertTransactionSucceeded(transactionHash: declaredContract.transactionHash)
        let deployedContract = try await client.deployContract(classHash: declaredContract.classHash)
        try await client.assertTransactionSucceeded(transactionHash: deployedContract.transactionHash)
    }

    func testDeclareDeployConstructor() async throws {
        let contract = try await client.declareDeployContract(contractName: "ContractWithConstructor", constructorCalldata: [2137, 451])
        try await client.assertTransactionSucceeded(transactionHash: contract.declare.transactionHash)
        try await client.assertTransactionSucceeded(transactionHash: contract.deploy.transactionHash)
    }

    func testInvokeContract() async throws {
        let calldata = [
            client.constants.predeployedAccount1.address,
            1000,
            0,
        ]
        let invokeResult = try await client.invokeContract(contractAddress: client.constants.ethErc20ContractAddress, function: "transfer", calldata: calldata)
        try await client.assertTransactionSucceeded(transactionHash: invokeResult.transactionHash)
    }
}
