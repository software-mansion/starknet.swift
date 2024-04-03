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
let account1PrivateKey: Felt = "0x71d7bb07b9a64f6f78ac4c816aff4da9"
let account2PrivateKey: Felt = "0xe1406455b7d66b1690803be066cbe5e"

// Addresses of accounts associated with above private keys.
let account1Address: Felt = "0x64b48806902a367c8598f4f95c305e8c1a1acba5f082d294a43793113115691"
let account2Address: Felt = "0x78662e7352d062084b0010068b99288486c2d8b914f6e2a55ce945f8792c8b1"

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
        // Normally we should use provider.getChainId()
        // for example purpose we can simply hardcode it as .goerli
        let chainId = StarknetChainId.goerli

        self.provider = StarknetProvider(url: rpcEndpoint)!

        // Create a signer that will be used to sign starknet transactions with provided private key.
        let account1Signer = StarkCurveSigner(privateKey: account1PrivateKey)!

        // With address, signer and provider you can create starknet account.
        // Please note that it will only work if it's already deployed.
        let account1 = StarknetAccount(
            address: account1Address,
            signer: account1Signer,
            provider: provider,
            chainId: chainId,
            cairoVersion: .one
        )

        // And do the same for the second account.
        let account2Signer = StarkCurveSigner(privateKey: account2PrivateKey)!

        let account2 = StarknetAccount(
            address: account2Address,
            signer: account2Signer,
            provider: provider,
            chainId: chainId,
            cairoVersion: .one
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
            let _ = try await senderAccount.executeV3(call: call)

            try await Task.sleep(nanoseconds: UInt64(Double(NSEC_PER_SEC)))

            await fetchBalance()

            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }
}
