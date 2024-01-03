import XCTest

import BigInt

@testable import CryptoToolkit
@testable import Starknet

final class PoseidonTests: XCTestCase {
    func testPoseidonHashSingleZero() {
        let zeroValue = Felt.zero
        let result = StarknetPoseidon.poseidonHash(zeroValue)
        XCTAssertEqual(result, Felt(fromHex: "0x60009f680a43e6f760790f76214b26243464cdd4f31fdc460baf66d32897c1b")!)
    }

    func testPoseidonHashSingleOne() {
        let oneValue = Felt.one
        let result = StarknetPoseidon.poseidonHash(oneValue)
        XCTAssertEqual(result, Felt(fromHex: "0x6d226d4c804cd74567f5ac59c6a4af1fe2a6eced19fb7560a9124579877da25")!)
    }

    func testPoseidonHashSingleBigNumber() {
        let value = Felt(BigUInt("737869762948382064636737869762948382064636737869762948382064636"))!
        let result = StarknetPoseidon.poseidonHash(value)
        XCTAssertEqual(result, Felt(fromHex: "0x1580978ed34d52bfbc78c9f21da6e9df1ed6544bf1dd561616b0aba45a40380")!)
    }

    func testPoseidonHashDoubleZero() {
        let zeroValue = Felt.zero
        let result = StarknetPoseidon.poseidonHash(first: zeroValue, second: zeroValue)
        XCTAssertEqual(result, Felt(fromHex: "0x293d3e8a80f400daaaffdd5932e2bcc8814bab8f414a75dcacf87318f8b14c5")!)
    }

    func testPoseidonHashDoubleBigNumbers() {
        let value = Felt(BigUInt("737869762948382064636737869762948382064636737869762948382064636"))!
        let result = StarknetPoseidon.poseidonHash(first: value, second: value)
        XCTAssertEqual(result, Felt(fromHex: "0x59c0ba54a2613d811726e10be9d6f7e01cf52d6d68ced0d16829027948cdfc3")!)
    }

    func testPoseidonHashManyAllZeros() {
        let zeroValue = Felt.zero
        let result = StarknetPoseidon.poseidonHash(zeroValue, zeroValue, zeroValue)
        XCTAssertEqual(result, Felt(fromHex: "0x29aee7812642221479b7e8af204ceaa5a7b7e113349fc8fb93e6303b477eb4d")!)
    }

    func testPoseidonHashManyZeros() {
        let zeroValue = Felt.zero
        let result = StarknetPoseidon.poseidonHash([zeroValue, zeroValue, zeroValue])
        XCTAssertEqual(result, Felt(fromHex: "0x29aee7812642221479b7e8af204ceaa5a7b7e113349fc8fb93e6303b477eb4d")!)
    }

    func testPoseidonHashManyRandomValues() {
        let result = StarknetPoseidon.poseidonHash([
            Felt(10),
            Felt(8),
            Felt(5),
        ])
        XCTAssertEqual(result, Felt(fromHex: "0x53aa661c2388b74f48a16163c38893760e26884211599194ffe264f14b5c6e7")!)
    }

    func testPoseidonHashManyBigNumbers() {
        let value1 = Felt(BigUInt("737869762948382064636737869762948382064636737869762948382064636"))!
        let value2 = Felt(BigUInt("948382064636737869762948382064636737869762948382064636737869762"))!
        let result = StarknetPoseidon.poseidonHash([value1, value2, value1])
        XCTAssertEqual(result, Felt(fromHex: "0xdaa82261a460722d8deb7d3bb2cb1838084887549df141540b6d88658d34ed")!)
    }

    func testPoseidonHash4NumbersZeros() {
        let zeroValue = Felt.zero
        let result = StarknetPoseidon.poseidonHash(zeroValue, zeroValue, zeroValue, zeroValue)
        XCTAssertEqual(result, Felt(fromHex: "0x5c4def9d0323f31f80e90c55fa780591ed2e2fee266491c0bd891aedac38935")!)
    }

    func testPoseidonHash4Numbers() {
        let result = StarknetPoseidon.poseidonHash([
            Felt.one,
            Felt(10),
            Felt(100),
            Felt(1000),
        ])
        XCTAssertEqual(result, Felt(fromHex: "0x51f923f87ee53d16c2d680c2c0c9eb0132ba255d52b6dd69f4b9918dcbe00a1")!)
    }

    func testPoseidonHash10NumbersZeros() {
        let zeroValue = Felt.zero
        let result = StarknetPoseidon.poseidonHash(Array(repeating: zeroValue, count: 10))
        XCTAssertEqual(result, Felt(fromHex: "0x7c19756199eacf9ac8c06ecab986929be144ee4a852db16f796435562e69c7c")!)
    }
}
