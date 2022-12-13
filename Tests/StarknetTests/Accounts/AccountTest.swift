import XCTest

@testable import Starknet

let erc20Address: Felt = "0x49D36570D4E46F48E99674BD3FCC84644DDD6B96F7C741B1562B82F9E004DC7"

final class AccountTests: XCTestCase {
    
    /*
     Temporary test file, until DevnetClient utility is created.
     
     To run, make sure you're running starknet-devnet on port 5050, with seed 0
     */
    
    func makeStarknetAccount() -> StarknetAccountProtocol {
        let url = "http://127.0.0.1:5050/rpc"
        let provider = StarknetProvider(starknetChainId: .testnet, url: url)!
        
        let signer = StarkCurveSigner(privateKey: "0xe3e70682c2094cac629f6fbed82c07cd")
        
        return StarknetAccount(address: "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a", signer: signer, provider: provider)
    }
    
    func testExecute() async throws {
        let account = makeStarknetAccount()
        
        let calldata: [Felt] = [
            "0x69b49c2cc8b16e80e86bfc5b0614a59aa8c9b601569c7b80dde04d3f3151b79",
            0,
            1000000000
        ]
        
        let call = StarknetCall(contractAddress: erc20Address, entrypoint: starknetSelector(from: "transfer"), calldata: calldata)
        let result = try await account.execute(call: call, maxFee: "0x1000000000")
        
        print(result.transactionHash)
    }
}

