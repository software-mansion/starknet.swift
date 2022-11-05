import Foundation

protocol ProviderProtocol {
    var starknetChainId: StarknetChainId { get }
    
    func callContract(_ call: Call, at blockId: BlockId?) async -> [Felt]
}
