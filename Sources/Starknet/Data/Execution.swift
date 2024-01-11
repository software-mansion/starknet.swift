import Foundation

public typealias StarknetCalldata = [Felt]
public typealias StarknetPaymasterData = [Felt]
public typealias StarknetAccountDeploymentData = [Felt]
public typealias StarknetSignature = [Felt]

public struct StarknetCall: Codable, Equatable {
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

public struct StarknetExecutionParamsV3 {
    public let nonce: Felt
    public let resourceBounds: StarknetResourceBoundsMapping
    public let tip: UInt64AsHex
    public let paymasterData: StarknetPaymasterData
    public let nonceDataAvailabilityMode: StarknetDAMode
    public let feeDataAvailabilityMode: StarknetDAMode
    
    public init(nonce: Felt, l1ResourceBounds: StarknetResourceBounds) {
        self.nonce = nonce
        // As of Starknet 0.13, most of v3 fields have hardcoded values.
        self.resourceBounds = StarknetResourceBoundsMapping(l1Gas: l1ResourceBounds)
        self.tip = .zero
        self.paymasterData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }
}

public struct StarknetDeprecatedExecutionParams {
    public let nonce: Felt
    public let maxFee: Felt

    public init(nonce: Felt, maxFee: Felt) {
        self.nonce = nonce
        self.maxFee = maxFee
    }
}

public struct StarknetOptionalExecutionParams {
    public let nonce: Felt?
    public let maxFee: Felt?

    public init(nonce: Felt? = nil, maxFee: Felt? = nil) {
        self.nonce = nonce
        self.maxFee = maxFee
    }
}

public func starknetCallsToExecuteCalldata(calls: [StarknetCall], cairoVersion: CairoVersion) -> [Felt] {
    switch cairoVersion {
    case .zero:
        return starknetCallsToExecuteCalldataCairo0(calls: calls)
    case .one:
        return starknetCallsToExecuteCalldataCairo1(calls: calls)
    }
}

private func starknetCallsToExecuteCalldataCairo0(calls: [StarknetCall]) -> [Felt] {
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

private func starknetCallsToExecuteCalldataCairo1(calls: [StarknetCall]) -> [Felt] {
    var callArray: [Felt] = []

    callArray.append(Felt(calls.count)!)

    calls.forEach { call in
        callArray.append(call.contractAddress)
        callArray.append(call.entrypoint)
        callArray.append(Felt(call.calldata.count)!)
        callArray.append(contentsOf: call.calldata)
    }

    return callArray
}
