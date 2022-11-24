import Foundation
import BigInt

public enum StarknetChainId {
    case mainnet
    case testnet
    
    public var feltValue: Felt {
        switch self {
        case .mainnet:
            return Felt(fromHex: "0x534e5f4d41494e")!
        case .testnet:
            return Felt(fromHex: "0x534e5f474f45524c49")!
        }
    }
}
