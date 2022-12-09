import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
    
    /*
     Temporary test file, until DevnetClient utility is created.
     
     To run, make sure you're running starknet-devnet on port 5050, with seed 0
     */
    
    func makeStarknetProvider() -> StarknetProviderProtocol {
        let url = "http://127.0.0.1:5050/rpc"
        return StarknetProvider(starknetChainId: .testnet, url: url)!
    }
    
    func testCall() async throws {
        let provider = makeStarknetProvider()
        
        let call = StarknetCall(
            contractAddress: Felt(fromHex: "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a")!,
            entrypoint: starknetSelector(from: "getPublicKey"),
            calldata: [])
        
        let result = try await provider.callContract(call)
        
        XCTAssertEqual(result.count, 1)
    }
    
    func testCallWithArguments() async throws {
        let provider = makeStarknetProvider()
        
        let call = StarknetCall(
            contractAddress: Felt(fromHex: "0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a")!,
            entrypoint: starknetSelector(from: "supportsInterface"),
            calldata: [Felt(2138)!])
        
        let result = try await provider.callContract(call)
        
        XCTAssertEqual(result[0], Felt.zero)
    }
    
//    func testAddInvokeTransaction() async throws {
//        let invokeTransaction = StarknetInvokeTransaction(calldata: <#T##StarknetCalldata#>, signature: <#T##StarknetSignature#>, maxFee: <#T##Felt#>, nonce: <#T##Felt#>)
//    }
}
