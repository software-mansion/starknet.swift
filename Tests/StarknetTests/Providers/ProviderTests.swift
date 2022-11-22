import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
    
    /*
     Temporary test file, until DevnetClient utility is created.
     
     To run, make sure you're running starknet-devnet on port 5050
     */
    
    func makeStarknetProvider() -> StarknetProviderProtocol {
        let url = "http://127.0.0.1:5050/rpc"
        return StarknetProvider(starknetChainId: .testnet, url: url)!
    }
    
    func testCall() async throws {
        let provider = makeStarknetProvider()
        
        let call = Call(
            contractAddress: Felt(fromHex: "0x27269bd63b8bc1fd67e52c3efafd51e0370831b13aa5c65fbb008aae6f0e18c")!,
            entrypoint: Felt(fromHex: "0x1a6c6a0bdec86cc645c91997d8eea83e87148659e3e61122f72361fd5e94079")!,
            calldata: [])
        
        let result = try await provider.callContract(call)
        
        XCTAssertEqual(result.count, 1)
    }
}
