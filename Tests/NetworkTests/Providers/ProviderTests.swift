import XCTest

@testable import Starknet

final class ProviderTests: XCTestCase {
    var provider: StarknetProviderProtocol!

    override class func setUp() {
        super.setUp()
    }

    override func setUp() async throws {
        try await super.setUp()

        // TODO(#245): Change this to internal node
        provider = StarknetProvider(url: "https://rpc.pathfinder.equilibrium.co/testnet-sepolia/rpc/v0_9")
    }

    func testGetBlockWithTxsWithLatestBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.latest))

        if case .preConfirmed = result {
            XCTFail("Expected .processed")
        }
    }

    func testGetBlockWithTxsWithPreConfirmedBlockTag() async throws {
        let result = try await provider.send(request: RequestBuilder.getBlockWithTxs(StarknetBlockId.BlockTag.preConfirmed))

        if case .processed = result {
            XCTFail("Expected .preConfirmed")
        }
    }

    func testGetBlockWithTxsWithBlockHash() async throws {
        let blockHash = Felt(fromHex: "0x05d95c778dad488e15f6a279c77c59322ad61eabf085cd8624ff5b39ca5ae8d8")!
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
