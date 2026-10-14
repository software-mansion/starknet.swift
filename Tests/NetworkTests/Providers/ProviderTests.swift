@testable import Starknet
import XCTest

final class ProviderTests: XCTestCase {
    var provider: StarknetProviderProtocol!

    override class func setUp() {
        super.setUp()
    }

    override func setUp() async throws {
        try await super.setUp()

        let environment = ProcessInfo.processInfo.environment
        guard let rpcURL = environment["SEPOLIA_RPC_URL"],
              let configuredProvider = StarknetProvider(url: rpcURL)
        else {
            throw XCTSkip("Set SEPOLIA_RPC_URL to run network integration tests")
        }

        provider = configuredProvider
    }

    func testGetBlockWithTxsWithL1AcceptedBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.l1Accepted))

        guard case .processed = result else {
            XCTFail("Expected result to be of type .processed")
            return
        }
    }

    func testGetBlockWithTxsWithLatestBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.latest))

        guard case .processed = result else {
            XCTFail("Expected result to be of type .processed")
            return
        }
    }

    func testGetBlockWithTxsWithPreConfirmedBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.preConfirmed))

        guard case .preConfirmed = result else {
            XCTFail("Expected result to be of type .preConfirmed")
            return
        }
    }

    func testGetBlockWithTxsWithBlockHash() async throws {
        let blockHash = try XCTUnwrap(Felt(fromHex: "0x05d95c778dad488e15f6a279c77c59322ad61eabf085cd8624ff5b39ca5ae8d8"))
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(blockHash))

        if case let .processed(processedBlock) = result {
            XCTAssertEqual(processedBlock.transactions.count, 7)
        } else {
            XCTFail("Expected .processed")
        }
    }

    func testGetBlockWithTxsWithBlockNumber() async throws {
        let blockNumber = 1_210_000
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(blockNumber))

        if case let .processed(processedBlock) = result {
            XCTAssertEqual(processedBlock.transactions.count, 8)
        } else {
            XCTFail("Expected .processed")
        }
    }
}
