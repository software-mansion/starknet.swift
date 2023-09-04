import XCTest

@testable import Starknet

final class MessageTests: XCTestCase {
    func testMessageToL1Decoding() throws {
        let json = """
        {
            "from_address": "0x42a0543842846269c710384612ac69418e2ad30b316fe4243717d2ec60494e4",
            "to_address": "0x0000000000000000000000000000000000000001",
            "payload": [
                "0xc",
                "0x22"
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertNoThrow(try decoder.decode(MessageToL1.self, from: json))
    }

    func testMessageFromL1Decoding() throws {
        let json = """
        {
            "from_address": "0xBe1259ff905cAdBbAA62514388b71BdEfB8aacC1",
            "to_address": "0x73314940630fd6dcda0d772d4c972c4e0a9946bef9dabf4ef84eda8ef542b82",
            "entry_point_selector": "0x2d757788a8d8d6f21d1cd40bce38a8222d70654214e96ff95d8086e684fbee5",
            "payload": [
                "0x2bf223f583a5940873cd804ef3333a8a9306e878b5d4a7d00881f1616894d4d",
                "0x16345785d8a0000",
                "0x0"
            ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        XCTAssertNoThrow(try decoder.decode(MessageFromL1.self, from: json))
    }

    func testMessageFromL1Encoding() throws {
        let messageFromL1 = MessageFromL1(
            fromAddress: "0xBe1259ff905cAdBbAA62514388b71BdEfB8aacC1",
            toAddress: "0x73314940630fd6dcda0d772d4c972c4e0a9946bef9dabf4ef84eda8ef542b82",
            entryPointSelector: "0x2d757788a8d8d6f21d1cd40bce38a8222d70654214e96ff95d8086e684fbee5",
            payload: ["0x2bf223f583a5940873cd804ef3333a8a9306e878b5d4a7d00881f1616894d4d", "0x16345785d8a0000", "0x0"]
        )

        let encoder = JSONEncoder()

        let encodedMessageFromL1 = try encoder.encode(messageFromL1)
        let encodedString = String(data: encodedMessageFromL1, encoding: .utf8)!

        let pairs = [
            "\"from_address\":\"0xBe1259ff905cAdBbAA62514388b71BdEfB8aacC1\"",
            "\"to_address\":\"0x73314940630fd6dcda0d772d4c972c4e0a9946bef9dabf4ef84eda8ef542b82\"",
            "\"entry_point_selector\":\"0x2d757788a8d8d6f21d1cd40bce38a8222d70654214e96ff95d8086e684fbee5\"",
            "\"payload\":[\"0x2bf223f583a5940873cd804ef3333a8a9306e878b5d4a7d00881f1616894d4d\",\"0x16345785d8a0000\",\"0x0\"]",
        ]

        pairs.forEach {
            XCTAssertTrue(encodedString.localizedStandardContains($0))
        }
    }
}
