import Foundation

enum HashMethod {
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
}