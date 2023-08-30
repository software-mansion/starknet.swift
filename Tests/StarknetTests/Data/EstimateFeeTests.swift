import XCTest

@testable import Starknet

final class EstimateFeeTests: XCTestCase {
    func testEstimateFeeParamsEncoding() throws {
        let invokeTransaction = StarknetSequencerInvokeTransaction(senderAddress: "0x6f8fa881a2a1305d874c3472962e84377d080862a7ab9241faf71e47e354fce", calldata: ["0x1", "0x5cd21d6b3952a869fda11fa9a5bd2657bd68080d3da255655ded47a81c8bd53", "0x1d7377b4b2053672e38039a02d909f73c4e538c9fddbb7e97aadf700cb9a01a", "0x0", "0x2", "0x2", "0x1d2c3b7a8", "0x451"], signature: ["0x54536091df45ce05f3f1bf3aeca81d7509927f77776ded4556032379dd14953", "0x2ecdae0ff4acaed3d071c7ae1ae3f38d822c41b5a8b0ab8e468844b1d87198b"], maxFee: 0, nonce: 1, forFeeEstimation: true)
        let estimateFeeParams = EstimateFeeParams(request: [invokeTransaction], blockId: .tag(.latest))

        let encoder = JSONEncoder()
        let encodedParams = try encoder.encode(estimateFeeParams)
        let encodedString = String(data: encodedParams, encoding: .utf8)!

        let pairs = [
            "\"request\":[{",
            "\"max_fee\":\"0x0\"",
            "\"calldata\":[\"0x1\",\"0x5cd21d6b3952a869fda11fa9a5bd2657bd68080d3da255655ded47a81c8bd53\",\"0x1d7377b4b2053672e38039a02d909f73c4e538c9fddbb7e97aadf700cb9a01a\",\"0x0\",\"0x2\",\"0x2\",\"0x1d2c3b7a8\",\"0x451\"",
            "\"signature\":[\"0x54536091df45ce05f3f1bf3aeca81d7509927f77776ded4556032379dd14953\",\"0x2ecdae0ff4acaed3d071c7ae1ae3f38d822c41b5a8b0ab8e468844b1d87198b\"]",
            "\"version\":\"0x100000000000000000000000000000001\"",
            "\"type\":\"INVOKE\"",
            "\"sender_address\":\"0x6f8fa881a2a1305d874c3472962e84377d080862a7ab9241faf71e47e354fce\"",
            "\"nonce\":\"0x1\"",
            "}]",
            "\"block_id\":\"latest\"",
        ]

        pairs.forEach {
            XCTAssertTrue(encodedString.localizedStandardContains($0))
        }
    }

    func testEstimateMessageFeeParamsEncoding() throws {
        let messageFromL1 = MessageFromL1(fromAddress: "0xbe1259ff905cadbbaa62514388b71bdefb8aacc1", toAddress: "0x73314940630fd6dcda0d772d4c972c4e0a9946bef9dabf4ef84eda8ef542b82", entryPointSelector: "0x2d757788a8d8d6f21d1cd40bce38a8222d70654214e96ff95d8086e684fbee5", payload: ["0x2bf223f583a5940873cd804ef3333a8a9306e878b5d4a7d00881f1616894d4d", "0x16345785d8a0000", "0x0"])
        let estimateMessageFeeParams = EstimateMessageFeeParams(message: messageFromL1, blockId: .number(306_687))

        let encoder = JSONEncoder()
        let encodedParams = try encoder.encode(estimateMessageFeeParams)
        let encodedString = String(data: encodedParams, encoding: .utf8)!

        let pairs = [
            "\"message\":{",
            "\"from_address\":\"0xBe1259ff905cAdBbAA62514388b71BdEfB8aacC1\"",
            "\"to_address\":\"0x73314940630fd6dcda0d772d4c972c4e0a9946bef9dabf4ef84eda8ef542b82\"",
            "\"entry_point_selector\":\"0x2d757788a8d8d6f21d1cd40bce38a8222d70654214e96ff95d8086e684fbee5\"",
            "\"payload\":[\"0x2bf223f583a5940873cd804ef3333a8a9306e878b5d4a7d00881f1616894d4d\",\"0x16345785d8a0000\",\"0x0\"]",
            "\"block_id\":{\"block_number\":306687}",
            "}}",
        ]

        pairs.forEach {
            XCTAssertTrue(encodedString.localizedStandardContains($0))
        }
    }

    func testEstimateFeeResponse() throws {
        let json = """
        {"gas_consumed":"0x4ddb","gas_price":"0x3cf96de7","overall_fee":"0x128b2f6f7f9d"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertNoThrow(try decoder.decode(StarknetFeeEstimate.self, from: json))
    }
}
