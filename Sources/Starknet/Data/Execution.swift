import Foundation

public typealias StarknetCalldata = [Felt]
public typealias StarknetSignature = [Felt]

public struct StarknetCall: Codable {
    public let contractAddress: Felt
    public let entrypoint: Felt
    public let calldata: StarknetCalldata
    
    public init(contractAddress: Felt, entrypoint: Felt, calldata: StarknetCalldata) {
        self.contractAddress = contractAddress
        self.entrypoint = entrypoint
        self.calldata = calldata
    }

    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case entrypoint = "entry_point_selector"
        case calldata
    }
}

public struct StarknetExecutionParams {
    public let nonce: Felt
    public let maxFee: Felt
}

func callsToExecuteCalldata(calls: [StarknetCall]) -> [Felt] {
    var wholeCalldata: [Felt] = []
    var callArray: [Felt] = []
    
    calls.forEach { call in
        callArray.append(call.contractAddress)
        callArray.append(call.entrypoint)
        callArray.append(Felt(wholeCalldata.count)!)
        callArray.append(Felt(call.calldata.count)!)
        
        wholeCalldata.append(contentsOf: call.calldata)
    }
    
    return [Felt(calls.count)!] + callArray + [Felt(wholeCalldata.count)!] + wholeCalldata
}
