import Foundation
import CryptoSwift
import BigInt

private let mask250 = BigUInt(2).power(250) - BigUInt(1)

internal func keccak(on bytes: [UInt8]) -> Felt {
    let hashed = bytes.sha3(.keccak256)
    let data = Data(hashed)
    let masked = BigUInt(data) & mask250
    
    return Felt(masked)!
}
