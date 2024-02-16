import XCTest

@testable import Starknet

final class StarknetChainIdTests: XCTestCase {
    static var chainIdCases: [(StarknetChainId, String, String)] = []

    override class func setUp() {
        self.chainIdCases = [
            (StarknetChainId.main, "SN_MAIN", "0x534e5f4d41494e"),
            (StarknetChainId.goerli, "SN_GOERLI", "0x534e5f474f45524c49"),
            (StarknetChainId.sepolia, "SN_SEPOLIA", "0x534e5f5345504f4c4941"),
            (StarknetChainId.integration_sepolia, "SN_INTEGRATION_SEPOLIA", "0x534e5f494e544547524154494f4e5f5345504f4c4941"),
        ]
    }

    func testFromHexInitializer() {
        for (chainId, _, hex) in Self.chainIdCases {
            XCTAssertEqual(StarknetChainId(fromHex: hex), chainId)
        }
    }

    func testFromNetworkNameInitializer() {
        for (chainId, name, _) in Self.chainIdCases {
            XCTAssertEqual(StarknetChainId(fromNetworkName: name), chainId)
        }
    }

    func testToNetworkName() {
        for (chainId, name, _) in Self.chainIdCases {
            XCTAssertEqual(chainId.toNetworkName(), name)
        }
    }

    func testEncoding() {
        for (chainId, _, hexString) in Self.chainIdCases {
            do {
                let data = try JSONEncoder().encode(chainId)
                let expectedData = Data("\"\(hexString)\"".utf8)
                XCTAssertEqual(data, expectedData)
            } catch {
                XCTFail("Failed to encode \(chainId)")
            }
        }
    }

    func testDecoding() {
        for (chainId, _, hexString) in Self.chainIdCases {
            do {
                let data = Data("\"\(hexString)\"".utf8)
                let decoded = try JSONDecoder().decode(StarknetChainId.self, from: data)
                XCTAssertEqual(decoded, chainId)
            } catch {
                XCTFail("Failed to decode \(chainId)")
            }
        }
    }

    func testCustomChainId() {
        let chainIdFromHex = StarknetChainId(fromHex: "0x4b4154414e41")
        let chainIdFromNetworkName = StarknetChainId(fromNetworkName: "KATANA")
        XCTAssertEqual(chainIdFromHex, chainIdFromNetworkName)
    }
}
