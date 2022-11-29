import XCTest

import BigInt

@testable import Starknet

private let privateKey = Felt(fromHex: "0x4070e7abfa479cf8a30d38895e93800a88862c4a65aa00e2b11495998818046")!
private let publicKey = Felt(fromHex: "0x7697f8f9a4c3e2b1efd882294462fda2ca9c439d02a3a04cf0a0cdb627f11ee")!

final class StarknetCurveTests: XCTestCase {
    
    func testSign() throws {
        let hash = Felt(fromHex: "0x052fc40e34aee86948cd47e1a0096fa67df8410f81421f314a1eb18102251a82")!
        
        let signature = try StarknetCurve.sign(privateKey: privateKey, hash: hash)
        
        let r = Felt(fromHex: "0x674a535c0b84fbabd8df411908842bb56d40e9c21197e95aafe9433e7807b8c")!
        let s = Felt(fromHex: "0x5eed1e83d0df6a22f1cd168331ae85a4c3b74022f3065531488ed0aaa5b0b3")!

        XCTAssertEqual(signature.r, r)
        XCTAssertEqual(signature.s, s)
        
        XCTAssertTrue(try StarknetCurve.verify(publicKey: publicKey, hash: hash, r: signature.r, s: signature.s))
    }
    
    func testSignWithK() throws {
        let hash = Felt(fromHex: "0x052fc40e34aee86948cd47e1a0096fa67df8410f81421f314a1eb18102251a82")!
        
        let signature = try StarknetCurve.sign(privateKey: privateKey, hash: hash, k: Felt(fromHex: "0x6d45bce40ffc4a8cd4cb656048d023a90913e70e589362b41e4334c721cec4b")!.value)
        
        let r = Felt(fromHex: "0x76a835cfbccd598b9429f6fce09acace91001abcfa68c36022e42dbdb024385")!
        let s = Felt(fromHex: "0x198ef0ca145ad0fbd175426788d9a7c84de3764f51bfc0fe0579caca660bfe4")!
        
        XCTAssertEqual(signature.r, r)
        XCTAssertEqual(signature.s, s)
        
        XCTAssertTrue(try StarknetCurve.verify(publicKey: publicKey, hash: hash, r: signature.r, s: signature.s))
    }
    
    func testPedersen() throws {
        let maxFelt = Felt(Felt.prime - BigUInt(1))!
        
        let cases = [
            (Felt(1)!, Felt(2)!, "0x5bb9440e27889a364bcb678b1f679ecd1347acdedcbf36e83494f857cc58026"),
            (Felt(0)!, Felt(0)!, "0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804"),
            (Felt(1)!, Felt(0)!, "0x268a9d47dde48af4b6e2c33932ed1c13adec25555abaa837c376af4ea2f8a94"),
            (Felt(0)!, Felt(1)!, "0x46c9aeb066cc2f41c7124af30514f9e607137fbac950524f5fdace5788f9d43"),
            (maxFelt, maxFelt, "0x7258fccaf3371fad51b117471d9d888a1786c5694c3e6099160477b593a576e"),
            (
                Felt(fromHex: "0x7abcde123245643903241432abcde")!,
                Felt(fromHex: "0x791234124214214728147241242142a89b812221c21d")!,
                "0x440a3075f082daa47147a22a4cd0c934ef65ea13ef87bf13adf45613e12f6ee"
            ),
            (
                Felt(fromHex: "0x46c9aeb066cc2f41c7124af30514f9e607137fbac950524f5fdace5788f9d43")!,
                Felt(fromHex: "0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804")!,
                "0x68ad69169c41c758ebd02e2fce51716497a708232a45a1b83e82fac1ade326e"
            ),
            (
                Felt(fromHex: "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad")!,
                Felt(fromHex: "0x43e637ca70a5daac877cba6b57e0b9ceffc5b37d28509e46b4fd2dee968a70c")!,
                "0x4b9281c85cfc5ab1f4046663135329020f57c1a88a50f4423eff37dd5fe81e8"
            ),
            (
                Felt(fromHex: "0x0")!,
                Felt(fromHex: "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad")!,
                "0x1a0c3e0f68c3ee702017fdb6452339244840eedbb70ab3d4f45e2affd1c9420"
            ),
        ]
        
        try cases.forEach {
            let result = try StarknetCurve.pedersen(first: $0, second: $1)
            print("\($0), \($1), \(result)")
            
            XCTAssertEqual(result, Felt(fromHex: $2)!)
        }
    }
    
    func testPedersenOnElements() throws {
        let cases = [
            ([], "0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804"),
            ([Felt(123782376)!, Felt(213984)!, Felt(128763521321)!], "0x7b422405da6571242dfc245a43de3b0fe695e7021c148b918cd9cdb462cac59"),
            (
                [Felt(fromHex: "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad")!,
                 Felt(fromHex: "0x10927538dee311ae5093324fc180ab87f23bbd7bc05456a12a1a506f220db25")!],
                "0x43e637ca70a5daac877cba6b57e0b9ceffc5b37d28509e46b4fd2dee968a70c"
            )
        ]
        
        try cases.forEach {
            let result = try StarknetCurve.pedersenOn(elements: $0)
            
            let expectedFelt = Felt(fromHex: $1)!
            
            XCTAssertEqual(result, expectedFelt)
        }
    }
    
    func testGetPublicKey() throws {
        let result = try StarknetCurve.getPublicKey(privateKey: privateKey)
        
        XCTAssertEqual(result, publicKey)
    }
    
    func testVerify() throws {
        let r = Felt(fromHex: "0x66f8955f5c4cbad5c21905ca2a968bc32a183e81069b851b7fc388eceaf57f1")!
        let s = Felt(fromHex: "0x13d5af50c934213f27a8cc5863aa304165aa886487fcc575fe6e1228879f9fe")!
        
        let positiveResult = try StarknetCurve.verify(publicKey: publicKey, hash: Felt(1)!, r: r, s: s)
        
        XCTAssertTrue(positiveResult)
        
        let negativeResult = try StarknetCurve.verify(publicKey: publicKey, hash: Felt(1)!, r: s, s: r)
        
        XCTAssertFalse(negativeResult)
    }
}
