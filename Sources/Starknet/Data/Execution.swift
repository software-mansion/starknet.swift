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

public struct StarknetInvokeParamsV3 {
    public let nonce: Felt
    public let resourceBounds: StarknetResourceBoundsMapping
    public let tip: UInt64AsHex
    public let paymasterData: StarknetPaymasterData
    public let accountDeploymentData: StarknetAccountDeploymentData
    public let nonceDataAvailabilityMode: StarknetDAMode
    public let feeDataAvailabilityMode: StarknetDAMode

    public init(nonce: Felt, resourceBounds: StarknetResourceBoundsMapping, tip: UInt64AsHex) {
        // As of Starknet 0.13, most of v3 fields have hardcoded values.
        self.nonce = nonce
        self.resourceBounds = resourceBounds
        self.tip = tip
        self.paymasterData = []
        self.accountDeploymentData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }

    public init(nonce: Felt, resourceBounds: StarknetResourceBoundsMapping) {
        self.init(nonce: nonce, resourceBounds: resourceBounds, tip: .zero)
    }
}

public struct StarknetOptionalInvokeParamsV3 {
    public let nonce: Felt?
    public let resourceBounds: StarknetResourceBoundsMapping?
    public let tip: UInt64AsHex
    public let paymasterData: StarknetPaymasterData
    public let accountDeploymentData: StarknetAccountDeploymentData
    public let nonceDataAvailabilityMode: StarknetDAMode
    public let feeDataAvailabilityMode: StarknetDAMode

    public init(nonce: Felt? = nil, resourceBounds: StarknetResourceBoundsMapping? = nil, tip: UInt64AsHex = .zero) {
        self.nonce = nonce
        self.resourceBounds = resourceBounds
        self.tip = tip
        self.paymasterData = []
        self.accountDeploymentData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }
}

public struct StarknetDeployAccountParamsV3 {
    public let nonce: Felt
    public let resourceBounds: StarknetResourceBoundsMapping
    public let tip: UInt64AsHex
    public let paymasterData: StarknetPaymasterData
    public let nonceDataAvailabilityMode: StarknetDAMode
    public let feeDataAvailabilityMode: StarknetDAMode

    public init(nonce: Felt, resourceBounds: StarknetResourceBoundsMapping, tip _: UInt64AsHex) {
        self.nonce = nonce
        self.resourceBounds = resourceBounds
        self.tip = .zero
        self.paymasterData = []
        self.nonceDataAvailabilityMode = .l1
        self.feeDataAvailabilityMode = .l1
    }

    public init(nonce: Felt, resourceBounds: StarknetResourceBoundsMapping) {
        self.init(nonce: nonce, resourceBounds: resourceBounds, tip: .zero)
    }

    public init(resourceBounds: StarknetResourceBoundsMapping) {
        self.init(nonce: .zero, resourceBounds: resourceBounds)
    }
}

public func starknetCallsToExecuteCalldata(calls: [StarknetCall], cairoVersion: CairoVersion) -> [Felt] {
    switch cairoVersion {
    case .zero:
        starknetCallsToExecuteCalldataCairo0(calls: calls)
    case .one:
        starknetCallsToExecuteCalldataCairo1(calls: calls)
    }
}

private func starknetCallsToExecuteCalldataCairo0(calls: [StarknetCall]) -> [Felt] {
    var wholeCalldata: [Felt] = []
    var callArray: [Felt] = []

    for call in calls {
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

    for call in calls {
        callArray.append(call.contractAddress)
        callArray.append(call.entrypoint)
        callArray.append(Felt(call.calldata.count)!)
        callArray.append(contentsOf: call.calldata)
    }

    return callArray
}
