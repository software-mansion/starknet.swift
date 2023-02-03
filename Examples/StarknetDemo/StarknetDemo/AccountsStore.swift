//
//  AccountsStore.swift
//  StarknetDemo
//
//  Created by Bartosz Rybarski on 20/01/2023.
//

import BigInt
import Foundation
import Starknet

let erc20: Felt = "0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7"

func makeAccount(provider: StarknetProviderProtocol, privateKey: Felt, address: Felt) -> StarknetAccountProtocol {
    let signer = StarkCurveSigner(privateKey: privateKey)!

    let account = StarknetAccount(
        address: address,
        signer: signer,
        provider: provider
    )

    return account
}

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
        let provider = StarknetProvider(starknetChainId: .testnet, url: "http://localhost:5050/rpc")!
        self.provider = provider

        let account1 = makeAccount(
            provider: provider,
            privateKey: "0xe3e70682c2094cac629f6fbed82c07cd",
            address: "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a"
        )

        let account2 = makeAccount(
            provider: provider,
            privateKey: "0xf728b4fa42485e3a0a5d2f346baa9455",
            address: "0x69b49c2cc8b16e80e86bfc5b0614a59aa8c9b601569c7b80dde04d3f3151b79"
        )

        self.accounts = [account1, account2]
        self.accountBalances = [0, 0]
    }

    func fetchBalance() async {
        let accountIndex = currentAccountIndex

        let call = StarknetCall(
            contractAddress: erc20,
            entrypoint: starknetSelector(from: "balanceOf"),
            calldata: [account.address]
        )

        do {
            let result = try await provider.callContract(call)

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
            contractAddress: erc20,
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
