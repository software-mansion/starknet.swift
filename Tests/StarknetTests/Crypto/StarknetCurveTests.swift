import XCTest

import BigInt

@testable import Starknet
@testable import CryptoToolkit

private let privateKey = Felt(fromHex: "0x4070e7abfa479cf8a30d38895e93800a88862c4a65aa00e2b11495998818046")!
private let publicKey = Felt(fromHex: "0x7697f8f9a4c3e2b1efd882294462fda2ca9c439d02a3a04cf0a0cdb627f11ee")!

final class StarknetCurveTests: XCTestCase {
    
    func testSign() throws {
        let privateKey = Felt(fromHex: "0x0139fe4d6f02e666e86a6f58e65060f115cd3c185bd9e98bd829636931458f79")!
        let publicKey = Felt(fromHex: "0x02c5dbad71c92a45cc4b40573ae661f8147869a91d57b8d9b8f48c8af7f83159")!
        
        let hash = Felt(fromHex: "0x06fea80189363a786037ed3e7ba546dad0ef7de49fccae0e31eb658b7dd4ea76")!
        
        let signature = try StarknetCurve.sign(privateKey: privateKey, hash: hash)
        
        let r = Felt(fromHex: "0x061ec782f76a66f6984efc3a1b6d152a124c701c00abdd2bf76641b4135c770f")!
        let s = Felt(fromHex: "0x04e44e759cea02c23568bb4d8a09929bbca8768ab68270d50c18d214166ccd9a")!
        
        XCTAssertEqual(signature.r, r)
        XCTAssertEqual(signature.s, s)
        
        let verifyResult = try StarknetCurve.verify(publicKey: publicKey, hash: hash, r: signature.r, s: signature.s)
        
//        print(Thread.current)
//        print("Before assert")
        print("Verify result in sign: \(verifyResult)")
        
        XCTAssertTrue(verifyResult)
    }
    
    func testSignWithK() throws {
        let hash = Felt(fromHex: "0x052fc40e34aee86948cd47e1a0096fa67df8410f81421f314a1eb18102251a82")!
        
        let signature = try StarknetCurve.sign(privateKey: privateKey, hash: hash, k: Felt(fromHex: "0x6d45bce40ffc4a8cd4cb656048d023a90913e70e589362b41e4334c721cec4b")!.value)
        
        let r = Felt(fromHex: "0x76a835cfbccd598b9429f6fce09acace91001abcfa68c36022e42dbdb024385")!
        let s = Felt(fromHex: "0x198ef0ca145ad0fbd175426788d9a7c84de3764f51bfc0fe0579caca660bfe4")!
        
        XCTAssertEqual(signature.r, r)
        XCTAssertEqual(signature.s, s)
        
        let verifyResult = try StarknetCurve.verify(publicKey: publicKey, hash: hash, r: signature.r, s: signature.s)
//
//        print(Thread.current)
//        print("Before assert")
//        print("Verify result in signWithK: \(verifyResult)")
//
//        do {
//            sleep(3)
//        }
        
        XCTAssertTrue(verifyResult)
    }
    
    func testPedersen() throws {
        let maxFelt = Felt(Felt.prime - BigUInt(1))!
        
        let cases: [(Felt, Felt, Felt)] = [
            (1, 2, "0x5bb9440e27889a364bcb678b1f679ecd1347acdedcbf36e83494f857cc58026"),
            (0, 0, "0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804"),
            (1, 0, "0x268a9d47dde48af4b6e2c33932ed1c13adec25555abaa837c376af4ea2f8a94"),
            (0, 1, "0x46c9aeb066cc2f41c7124af30514f9e607137fbac950524f5fdace5788f9d43"),
            (maxFelt, maxFelt, "0x7258fccaf3371fad51b117471d9d888a1786c5694c3e6099160477b593a576e"),
            (
                "0x7abcde123245643903241432abcde",
                "0x791234124214214728147241242142a89b812221c21d",
                "0x440a3075f082daa47147a22a4cd0c934ef65ea13ef87bf13adf45613e12f6ee"
            ),
            (
                "0x46c9aeb066cc2f41c7124af30514f9e607137fbac950524f5fdace5788f9d43",
                "0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804",
                "0x68ad69169c41c758ebd02e2fce51716497a708232a45a1b83e82fac1ade326e"
            ),
            (
                "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad",
                "0x43e637ca70a5daac877cba6b57e0b9ceffc5b37d28509e46b4fd2dee968a70c",
                "0x4b9281c85cfc5ab1f4046663135329020f57c1a88a50f4423eff37dd5fe81e8"
            ),
            (
                "0x0",
                "0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad",
                "0x1a0c3e0f68c3ee702017fdb6452339244840eedbb70ab3d4f45e2affd1c9420"
            ),
        ]
        
        cases.forEach {
            let result = StarknetCurve.pedersen(first: $0, second: $1)
            
            XCTAssertEqual(result, $2)
        }
    }
    
    func testPedersenOnElements() throws {
        let cases: [([Felt], Felt)] = [
            ([], "0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804"),
            ([123782376, 213984, 128763521321], "0x7b422405da6571242dfc245a43de3b0fe695e7021c148b918cd9cdb462cac59"),
            (
                ["0x15d40a3d6ca2ac30f4031e42be28da9b056fef9bb7357ac5e85627ee876e5ad",
                 "0x10927538dee311ae5093324fc180ab87f23bbd7bc05456a12a1a506f220db25"],
                "0x43e637ca70a5daac877cba6b57e0b9ceffc5b37d28509e46b4fd2dee968a70c"
            )
        ]
        
        cases.forEach {
            let result = StarknetCurve.pedersenOn($0)
            
            let expectedFelt = $1
            
            XCTAssertEqual(result, expectedFelt)
        }
    }
    
    func testGetPublicKey() throws {
        let result = try StarknetCurve.getPublicKey(privateKey: privateKey)
        
        XCTAssertEqual(result, publicKey)
        
        XCTAssertThrowsError(try StarknetCurve.getPublicKey(privateKey: Felt.zero))
    }
    
    func testVerify() throws {
        let r = Felt(fromHex: "0x66f8955f5c4cbad5c21905ca2a968bc32a183e81069b851b7fc388eceaf57f1")!
        let s = Felt(fromHex: "0x13d5af50c934213f27a8cc5863aa304165aa886487fcc575fe6e1228879f9fe")!
        
        do {
            let positiveResult = try StarknetCurve.verify(publicKey: publicKey, hash: 1, r: r, s: s)
            XCTAssertTrue(positiveResult)
        } catch let e {
            print("Verify error 1: \(e)")
        }
        
        do {
            let negativeResult = try StarknetCurve.verify(publicKey: publicKey, hash: 1, r: s, s: r)
            XCTAssertFalse(negativeResult)
        } catch let e {
            print("Verify error 2: \(e)")
        }
    }
    
    func testVerifyWithIncorrectArguments() throws {
        do {
            try StarknetCurve.verify(publicKey: .zero, hash: .zero, r: .one, s: .one)
        } catch let e {
            print(e)
        }
    }
    
    func testKGeneration() throws {
        let cases: [(Felt, Felt, Felt, String)] = [
            ("0x010b559a3b4dc1b7137d90521cb413b397ff07963214d128a92d65aec7182f68",
            "0x07e3184f4bef18f371bc53fc412dff1b30dbc94f758490fb8e2349bae647a642",
            "0x03fe27199aaad4e700559e2436a919f4de70def585a6deb2f4c087fdf6a27c1b",
            "00514de5048c11bf01f3dc98a131e0a3fde03d6269cdfab69d944c8281149184"),
            ("0x058a8fc2bed05af3ae202f0ea4f6e724b6d3b1034382c7a2e1a3a06bd48bf7ea",
            "0x00efacf45682998e4748e853f13a789b4729be197353eb1b8063fd425e0576f8",
            "0x05a595cc1e2dcdb26e2ee3964aaa55090bff0c02be6980f098669bc8c87fb994",
            "0610bd4aec3a26b00331daee8baefc2ad9c94eab42d21384851a1c4fcd5c0483"),
            ("0x02de2f0d139af136ef15a5ccf8139724131ff6000034be37e281b37a33b06ed7",
            "0x01d2cb8a451ddbe6d0d2f193cf384c275e919e18aeb4aa09e39c2236dd5d4121",
            "0x033fe7b36cb79df110f92739f13fcf9c1a9ed9f80dba80a724f73055d763eb94",
            "06019bb42abee70ad655cf5135f35a6fa38ccfa7823abd238e5742d979dcd470"),
            ("0x05379d4cabb167483ffeeec5463452a021092773ae2d3c9fa639e501cbd337cb",
            "0x062465a3562e57a73e4fbdbc3dc4c7b14138258639a276410fbc553d951f498e",
            "0x0603a421b6a665a83efcba9bff5361d728ae96096e3305b0a17df896b54c3832",
            "00c1bc03501b4c521310a5f47f020899f63079d20268126ebf5237c4fe40cc06"),
            ("0x0605b776d195609f6ed6ebacb20efb1859b7c827abfa9743c4541e1eb48f1c2d",
            "0x00a13a4fa63b534583089df4d6f5ff74ca3cbc2679c4161e076969803cae1aac",
            "0x0104c78975779c741a5a5c0a6f5edc8841f570ded6a1c5c519ab0f963ec64c0a",
            "07badb8d84631f6bd418e5eaa46e9b09c083fa607c879e881cf5c31923520e3a"),
            ("0x01856e6d1c3ce0a34ab04992b4a8d8d9ef756a4044bfc0a5f8068013f829ee17",
            "0x01e20f779df440c3fca66a3ede6f43c68ba60222b23f893854f55c5138c77a1c",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "01bdbdc2db77b6dad0c9bdaca20acb5a78a61200c711cc2dcaeebcb86f9ef1ca"),
            ("0x0438e872bae2e39e148ab372c6aa4506602d9d0f0acca48dfa853e858e38a8aa",
            "0x02d50c10d13ecf299d6bccea372efd6b0212208fd5f04cca66e5072d89b9bc2f",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "051a3dd43ef8e85094c95ca1d6d5f4cbd5a2c8253466d558a815dde2bae17b76"),
            ("0x0470d8bd5f6640bbae27a997f5da4493953a2f6c2aacb7ac3a26cfe810738470",
            "0x01af592805ccb005eed4ce5b1997193c7446786b1d8c3cdc9fb30b84ea084cd6",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "004e29ac94c51097d4ee87d4bf9bcfc33ca29518f73e972e725f851ada274a57"),
            ("0x04d85b6e736dd4aa07a8b1222819585f99e122a09f7e9c77e22da288f9c893b0",
            "0x046dda98ddd7337b4f6248795aedbc2e1b192466356ab8f61ee25317500e3a22",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "014ee0f4a9e8b4f98d48d47993788d8485ded1eca3c894c8501b31dbcd8190e5"),
            ("0x03fcafdbc49c1b8ff00ad5884db731a643899a2010169481203e9a4aab0545f3",
            "0x02bb48d586e127c86a3a4e6b831a99bac5a9adf0e3974bc629c43a12f52fb488",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "0052218bd1d5447347793972e5d40800a45cc91794746533164827e6f3ce8250"),
            ("0x0080977da1148412a7976215729d396b72aec9e955498757a7b859281354b4b1",
            "0x03fa56dcdbe2fb6769a83786469faf589a3d1e31c66db8b0432f741a38cdeed1",
            "0x0776cc1aa4c66417a4923768b9d4a7cfca731e862e4972ed930d8f2ad45d352b",
            "0013480c97bb5861404aa16e1f97a99411ba8f4039b2d54de839dea5c9f0af47"),
            ("0x00acf1ce22cb1f49d4fc7a6df93cd290d28f4c5a27888c9624b07cfa193de992",
            "0x06ad6342c62315862f51722808d2764a60824f9c5894105dffbb6478cfb06a95",
            "0x01314de4fcf69889ea0cdf4aefd1cc7732d1dfbdc6476066e3132c1609756bd0",
            "0687b462764b919fabefcb84fe77a4eae838f45b97f49b2d24fec995ff482c04"),
            ("0x0020791e67f0d6083d406a3a0fdaf8f4008fc1c6616dc97c1e1fdda352030e2f",
            "0x06e18a4a890962776c397e3ddf659b07275995a341e32bb75cd5a3bff55cfe7b",
            "0x0506b182cf3d46d6a7918ed4dfcced8f46c09a44c68067b3b40f2d82bee65e1a",
            "02cc9d2484afa0569b44487cf1705906db0a4cb78d9f73426efaaa572a5d47bb"),
            ("0x006243fd868f3e5b1852a9bda7a93780405cd05e5809904837398343c649c863",
            "0x0752543710a5075733d597329ff9ef354a2d4a36dbf769a6293a4fd0082026be",
            "0x06a7c98da9ea1f2abd105b5cf6722f0d03efadb60891b8d58c79c7a9fc2649a2",
            "02e701fb8707ecd930bea12f9761cfedd9f559d1706a104d3f529d4f7b43223a"),
            ("0x00b3b40642edd4d2e4c7c60310c55b9e99bcb64b57b05ccd3d4062b6caa10bfc",
            "0x05a1e54cd91afff6b1797ad6244a93380cd530f05eda201b9b25d52da61fbcb2",
            "0x00343ace243e3236520d132a07a6bdd757f743e5a4901e7b5d60b72c3f9450af",
            "05bb9f6160e41bd0887b58c40c90060a32569de14dcab341426b16bdf4d9dd94"),
            ("0x006c663dc46f1f680f32ef5f3f4fe71c5a0488c7fd2500eeee29cbaa3e4231e3",
            "0x013a6f2b21a9344b51635f16da58573f69c7d09ec20769ec9b481629ea9ec485",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "02d59476386604375e958f2ee7f07446d1861a4ceb92eb393009b1c72db308a7"),
            ("0x006c846f23ae7941f843c53cf86004e0addb8974bdfc5d051035edbfd3dcf836",
            "0x0562bb91276d2463e3186631dcff433169e99592639e0df9f358c56437e90c9a",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "076e1465a3753e7b1139223d9f68880c6192cd19f68b2a1c43b34b7aaa8cab16"),
            ("0x00539c45625f25004f965082e1e7f5a837f4eee253c915a95f00503fcdfb2c35",
            "0x05f4dddfc752dd28e72f498c7c0298a42fa6cfef14db2c3bdd798c6ca5b1497b",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "06054d0413882a9798127d5760d61dc9e3e940b11ccc353deb33ef4ca58ccf34"),
            ("0x0050b1346abe44d73084f557fc88f209ae4aadff253bb23b4212f859076f8755",
            "0x0580cf0b0db0ffb7b792b61d6d3da583210b320337a9222ab4208aae78ce4963",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "052b8601d62662702ed36ee1440d1f76ef814193d206218e436ccd3aae25451e"),
            ("0x0054077f197503c09c1265254398f57fb79f3a4f6a5a143cf871d58eeb5a5729",
            "0x07e69dd5b7cf548d598650be2ab3a8ebc038a5877a592d35a1cafa7249ef7fc4",
            "0x0000000000000000000000000000000000000000000000000000000000000000",
            "07af7d6cf50798dd5fa6e5731394d7d33f16dd57cca4169d63256a2b42179649")
        ]
        
        // Test cases from starknet-rs. Testing whether there are no problems with data conversion between
        // swift and rust parts.
        
        try cases.forEach { (hash, key, seed, k) in
            let generatedKey = try CryptoRs.getRfc6979Nonce(hash: hash.serialize(), privateKey: key.serialize(), seed: seed.serialize())
            
            let keyUInt = BigUInt(generatedKey)
            
            XCTAssertEqual(BigUInt(k, radix: 16), keyUInt)
        }
    }
}
