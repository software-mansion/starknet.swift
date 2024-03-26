import Foundation

enum HashMethod {
    case pedersen
    case poseidon

    func hash(values: [Felt]) -> Felt {
        switch self {
        case .pedersen:
            return StarknetCurve.pedersenOn(values)
        case .poseidon:
            return StarknetPoseidon.poseidonHash(values)
        }
    }
}
