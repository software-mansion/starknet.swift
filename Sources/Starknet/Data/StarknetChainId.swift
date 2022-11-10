import Foundation
import BigInt

enum StarknetChainId {
    case mainnet
    case testnet
    
    var feltValue: Felt {
        switch self {
        case .mainnet:
            return Felt(fromHex: "0x534e5f4d41494e")!
        case .testnet:
            return Felt(fromHex: "0x534e5f474f45524c49")!
        }
    }
}
