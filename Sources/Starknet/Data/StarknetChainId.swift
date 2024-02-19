import BigInt
import Foundation

public enum StarknetChainId: String, Codable, Equatable {
    case mainnet = "0x534e5f4d41494e"
    case goerli = "0x534e5f474f45524c49"
    case sepolia = "0x534e5f5345504f4c4941"
    case integration_sepolia = "0x534e5f494e544547524154494f4e5f5345504f4c4941"

    public var feltValue: Felt {
        Felt(fromHex: self.rawValue)!
    }

    enum CodingKeys: String, CodingKey {
        case mainnet = "0x534e5f4d41494e"
        case goerli = "0x534e5f474f45524c49"
        case sepolia = "0x534e5f5345504f4c4941"
        case integration_sepolia = "0x534e5f494e544547524154494f4e5f5345504f4c4941"
    }
}
