import BigInt
import Foundation
@testable import Starknet

enum SnCastResponseWrapper: Decodable {
    fileprivate enum Keys: String, CodingKey {
        case command
        case error
    }

    case accountCreate(AccountCreateSnCastResponse)
    case accountDeploy(AccountDeploySnCastResponse)
    case declare(DeclareSnCastResponse)
    case deploy(DeploySnCastResponse)

    public var response: any SnCastResponse {
        switch self {
        case let .accountCreate(res):
            return res
        case let .accountDeploy(res):
            return res
        case let .declare(res):
            return res
        case let .deploy(res):
            return res
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let command = try container.decode(SnCastCommand.self, forKey: .command)
        let error = try container.decodeIfPresent(String.self, forKey: .error)
        guard error == nil else {
            throw SnCastError.commandFailed(error!)
        }

        switch command {
        case .accountCreate:
            self = try .accountCreate(AccountCreateSnCastResponse(from: decoder))
        case .accountDeploy:
            self = try .accountDeploy(AccountDeploySnCastResponse(from: decoder))
        case .declare:
            self = try .declare(DeclareSnCastResponse(from: decoder))
        case .deploy:
            self = try .deploy(DeploySnCastResponse(from: decoder))
        default:
            throw SnCastError.invalidCommandType
        }
    }
}
