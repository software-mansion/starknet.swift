@testable import Starknet
import XCTest

final class devnetClientTests: XCTestCase {
    var client: DevnetClientProtocol!

    override func setUp() async throws {
        client = makeDevnetClient()
        try await client.start()
    }

    override func tearDown() async throws {
        client.close()
    }

    func testCreateDeployAccount() async throws {
        let account = try await client.createDeployAccount(name: "Account1")
        try await client.assertTransactionSucceeded(transactionHash: account.transactionHash)

        let account2 = try await client.createDeployAccount()
        try await client.assertTransactionSucceeded(transactionHash: account2.transactionHash)
    }

    func testCreateAndDeployAccount() async throws {
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
        let invokeResult = try await client.invokeContract(contractAddress: client.constants.erc20ContractAddress, function: "transfer", calldata: calldata)
        try await client.assertTransactionSucceeded(transactionHash: invokeResult.transactionHash)
    }
}
