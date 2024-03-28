import Foundation

public enum StarknetHashMethod {
    case pedersen
    case poseidon

    func hash(values: [Felt]) -> Felt {
        switch self {
        case .pedersen:
            StarknetCurve.pedersenOn(values)
        case .poseidon:
            StarknetPoseidon.poseidonHash(values)
        }
    }

    func hash(first: Felt, second: Felt) -> Felt {
        switch self {
        case .pedersen:
            StarknetCurve.pedersen(first: first, second: second)
        case .poseidon:
            StarknetPoseidon.poseidonHash(first: first, second: second)
        }
    }
}
