//
//  AccountsStore.swift
//  StarknetDemo
//
//  Created by Bartosz Rybarski on 20/01/2023.
//

import BigInt
import Foundation
import Starknet

// Address of the native erc20 contract in starknet-devnet.
let erc20ContractAddress: Felt = "0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7"

// In this demo, you can interact with two predeployed accounts.
// Please run starknet-devnet as follows:
// starknet-devnet --port 5050 --seed 0
// to be able to use the accounts defined below.
// If you used a different seed update private keys and account addresses accordingly.
// If you used a different port, please change it below as well.

// Address to the the rpc endpoint of a local devnet instance
let rpcEndpoint = "http://127.0.0.1:5050/rpc"

// !!! Important !!!
// These private keys are for demo only. Never publish a privateKey of your wallet, nor
// store it in any repository as plain text.
let account1PrivateKey: Felt = "0xe3e70682c2094cac629f6fbed82c07cd"
let account2PrivateKey: Felt = "0xf728b4fa42485e3a0a5d2f346baa9455"

// Addresses of accounts associated with above private keys.
let account1Address: Felt = "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a"
let account2Address: Felt = "0x69b49c2cc8b16e80e86bfc5b0614a59aa8c9b601569c7b80dde04d3f3151b79"

class AccountsStore: ObservableObject {
    let accounts: [StarknetAccountProtocol]
    let provider: StarknetProviderProtocol

    @Published var currentAccountIndex = 0 {
        didSet {
            Task {
                await fetchBalance()
            }
        }
    }

    @Published var accountBalances: [BigUInt]

    @Published var loading = false

    var account: StarknetAccountProtocol {
        accounts[currentAccountIndex]
    }

    var balance: BigUInt {
        accountBalances[currentAccountIndex]
    }

    init() {
        // Create starknet provider that will be used to communicate with the given starknet node.
        self.provider = StarknetProvider(starknetChainId: .testnet, url: rpcEndpoint)!

        // Create a signer that will be used to sign starknet transactions with provided private key.
        let account1Signer = StarkCurveSigner(privateKey: account1PrivateKey)!

        // With address, signer and provider you can create starknet account.
        // Please note that it will only work if it's already deployed.
        let account1 = StarknetAccount(
            address: account1Address,
            signer: account1Signer,
            provider: provider
        )

        // And do the same for the second account.
        let account2Signer = StarkCurveSigner(privateKey: account2PrivateKey)!

        let account2 = StarknetAccount(
            address: account2Address,
            signer: account2Signer,
            provider: provider
        )

        self.accounts = [account1, account2]
        self.accountBalances = [0, 0]
    }

    func fetchBalance() async {
        let accountIndex = currentAccountIndex

        // Prepare a read call to be sent to starknet
        let call = StarknetCall(
            contractAddress: erc20ContractAddress,
            entrypoint: starknetSelector(from: "balanceOf"),
            calldata: [account.address]
        )

        do {
            // Note that as it is a read only call, you can send it using provider.
            let result = try await provider.callContract(call)

            // This erc20 contract uses uint256 instead of felt for balances, which is stored
            // as two felts - lower and upper 128 bits of the uint256.
            let balanceValue = result[0].value + result[1].value << 128

            DispatchQueue.main.async {
                self.accountBalances[accountIndex] = balanceValue
            }
        } catch {
            print("Fetching balance failed with error: \(error)")
        }
    }

    func transferTokens(amountString: String) {
        guard !loading else {
            return
        }

        loading = true

        guard let amount = BigUInt(amountString) else {
            return
        }

        let (high, low) = amount.quotientAndRemainder(dividingBy: BigUInt(2).power(128))

        let recipientAccoutnIndex = accounts.count - 1 - currentAccountIndex
        let recipientAddress = accounts[recipientAccoutnIndex].address

        let call = StarknetCall(
            contractAddress: erc20ContractAddress,
            entrypoint: starknetSelector(from: "transfer"),
            calldata: [recipientAddress, low.toFelt()!, high.toFelt()!]
        )

        let senderAccount = accounts[currentAccountIndex]

        Task {
            let _ = try await senderAccount.execute(call: call)

            try await Task.sleep(nanoseconds: UInt64(Double(NSEC_PER_SEC)))

            await fetchBalance()

            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }
}
