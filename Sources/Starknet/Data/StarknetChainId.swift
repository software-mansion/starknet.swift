import BigInt
import Foundation

public struct StarknetChainId: Codable, Equatable {
    public let value: Felt

    public static let main = StarknetChainId(fromHex: "0x534e5f4d41494e")
    public static let goerli = StarknetChainId(fromHex: "0x534e5f474f45524c49")
    public static let sepolia = StarknetChainId(fromHex: "0x534e5f5345504f4c4941")
    public static let integration_sepolia = StarknetChainId(fromHex: "0x534e5f494e544547524154494f4e5f5345504f4c4941")

    public init(_ value: Felt) {
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self.value = Felt(fromHex: value)!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }

    enum CodingKeys: String, CodingKey {
        case mainnet = "0x534e5f4d41494e"
        case goerli = "0x534e5f474f45524c49"
        case sepolia = "0x534e5f5345504f4c4941"
        case integration_sepolia = "0x534e5f494e544547524154494f4e5f5345504f4c4941"
    }
}

public extension StarknetChainId {
    init(fromHex hex: String) {
        self.value = Felt(fromHex: hex)!
    }

    init(fromNetworkName networkName: String) {
        self.value = Felt.fromShortString(networkName)!
    }

    func toNetworkName() -> String {
        self.value.toShortString()
    }
}
