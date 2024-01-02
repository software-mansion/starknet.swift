import BigInt
import CryptoToolkit
import Foundation

public enum Poseidon {
    public static func poseidonHash(x: Felt, y: Felt) -> Felt {
        let result = CryptoPoseidon.poseidonHash(x: x.value, y: y.value)

        return Felt(result)!
    }
}
