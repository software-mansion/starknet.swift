import Foundation

public protocol StarknetResources: Decodable, Equatable {
    var steps: Int { get }
    var memoryHoles: Int? { get }
    var rangeCheckApplications: Int? { get }
    var pedersenApplications: Int? { get }
    var poseidonApplications: Int? { get }
    var ecOpApplications: Int? { get }
    var ecdsaApplications: Int? { get }
    var bitwiseApplications: Int? { get }
    var keccakApplications: Int? { get }
}

public struct StarknetComputationResources: StarknetResources {
    public let steps: Int
    public let memoryHoles: Int?
    public let rangeCheckApplications: Int?
    public let pedersenApplications: Int?
    public let poseidonApplications: Int?
    public let ecOpApplications: Int?
    public let ecdsaApplications: Int?
    public let bitwiseApplications: Int?
    public let keccakApplications: Int?

    enum CodingKeys: String, CodingKey {
        case steps
        case memoryHoles = "memory_holes"
        case rangeCheckApplications = "range_check_builtin_applications"
        case pedersenApplications = "pedersen_builtin_applications"
        case poseidonApplications = "poseidon_builtin_applications"
        case ecOpApplications = "ec_op_builtin_applications"
        case ecdsaApplications = "ecdsa_builtin_applications"
        case bitwiseApplications = "bitwise_builtin_applications"
        case keccakApplications = "keccak_builtin_applications"
    }
}

public struct StarknetExecutionResources: StarknetResources {
    public let steps: Int
    public let memoryHoles: Int?
    public let rangeCheckApplications: Int?
    public let pedersenApplications: Int?
    public let poseidonApplications: Int?
    public let ecOpApplications: Int?
    public let ecdsaApplications: Int?
    public let bitwiseApplications: Int?
    public let keccakApplications: Int?
    public let dataAvailability: StarknetDataAvailability

    enum CodingKeys: String, CodingKey {
        case steps
        case memoryHoles = "memory_holes"
        case rangeCheckApplications = "range_check_builtin_applications"
        case pedersenApplications = "pedersen_builtin_applications"
        case poseidonApplications = "poseidon_builtin_applications"
        case ecOpApplications = "ec_op_builtin_applications"
        case ecdsaApplications = "ecdsa_builtin_applications"
        case bitwiseApplications = "bitwise_builtin_applications"
        case keccakApplications = "keccak_builtin_applications"
        case dataAvailability = "data_availability"
    }
}

public struct StarknetDataAvailability: Decodable, Equatable {
    public let l1Gas: Int
    public let l1DataGas: Int

    enum CodingKeys: String, CodingKey {
        case l1Gas = "l1_gas"
        case l1DataGas = "l1_data_gas"
    }
}

