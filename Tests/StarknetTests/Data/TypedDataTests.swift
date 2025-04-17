//
//  TypedDataTests.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//
import BigInt
@testable import Starknet
import XCTest

final class TypedDataTests: XCTestCase {
    enum CasesRev0 {
        static let td = try! loadTypedDataFromFile(name: "typed_data_rev_0_example")
        static let tdFeltArr = try! loadTypedDataFromFile(name: "typed_data_rev_0_felt_array_example")
        static let tdString = try! loadTypedDataFromFile(name: "typed_data_rev_0_long_string_example")
        static let tdStructArr = try! loadTypedDataFromFile(name: "typed_data_rev_0_struct_array_example")
        static let tdStructMerkleTree = try! loadTypedDataFromFile(name: "typed_data_rev_0_struct_merkletree_example")
        static let tdValidate = try! loadTypedDataFromFile(name: "typed_data_rev_0_validate_example")
    }

    enum CasesRev1 {
        static let td = try! loadTypedDataFromFile(name: "typed_data_rev_1_example")
        static let tdFeltMerkleTree = try! loadTypedDataFromFile(name: "typed_data_rev_1_felt_merkletree_example")
        static let tdBasicTypes = try! loadTypedDataFromFile(name: "typed_data_rev_1_basic_types_example")
        static let tdPresetTypes = try! loadTypedDataFromFile(name: "typed_data_rev_1_preset_types_example")
        static let tdEnum = try! loadTypedDataFromFile(name: "typed_data_rev_1_enum_example")
    }

    static let domainTypeV0 = (
        "StarkNetDomain",
        [
            StarknetTypedData.StandardType(name: "name", type: "felt"),
            StarknetTypedData.StandardType(name: "version", type: "felt"),
            StarknetTypedData.StandardType(name: "chainId", type: "felt"),
        ]
    )
    static let domainTypeV1 = (
        "StarknetDomain",
        [
            StarknetTypedData.StandardType(name: "name", type: "shortstring"),
            StarknetTypedData.StandardType(name: "version", type: "shortstring"),
            StarknetTypedData.StandardType(name: "chainId", type: "shortstring"),
            StarknetTypedData.StandardType(name: "revision", type: "shortstring"),
        ]
    )

    static let exampleDomainV0 = """
    {
        "name": "DomainV0",
        "version": "1",
        "chainId": 2137,
    }
    """
    static let exampleDomainV1 = """
    {
        "name": "DomainV1",
        "version": "2",
        "chainId": "2137",
        "revision": 1
    }
    """

    private func makeTypedData(_ type: String, _ revision: StarknetTypedData.Revision) throws -> StarknetTypedData {
        let (domainType, domain) = switch revision {
        case .v0: (Self.domainTypeV0, Self.exampleDomainV0)
        case .v1: (Self.domainTypeV1, Self.exampleDomainV1)
        }

        return try StarknetTypedData(
            types: [
                type: [],
                domainType.0: domainType.1,
            ],
            primaryType: type,
            domain: domain,
            message: "{\"\(type)\": 1}"
        )
    }

    func testInvalidTypeNames() {
        try XCTAssertThrowsError(makeTypedData("", .v1)) { error in
            XCTAssertEqual(error as? StarknetTypedDataError, .invalidTypeName(""))
        }
        try XCTAssertThrowsError(makeTypedData("myType*", .v1)) { error in
            XCTAssertEqual(error as? StarknetTypedDataError, .invalidTypeName("myType*"))
        }
        try XCTAssertThrowsError(makeTypedData("(myType)", .v1)) { error in
            XCTAssertEqual(error as? StarknetTypedDataError, .invalidTypeName("(myType)"))
        }
        try XCTAssertThrowsError(makeTypedData("()", .v1)) { error in
            XCTAssertEqual(error as? StarknetTypedDataError, .invalidTypeName("()"))
        }
        try XCTAssertThrowsError(StarknetTypedData(types: [Self.domainTypeV0.0: Self.domainTypeV1.1, "myType": [StarknetTypedData.StandardType(name: "value", type: "(u128)")]], primaryType: "myType", domain: Self.exampleDomainV0, message: "{}")) { error in
            XCTAssertEqual(error as? StarknetTypedDataError, .unsupportedType("(u128)"))
        }
    }

    func testTypesRedifintion() throws {
        func testBasicTypeRedifintion(_ type: String, _ revision: StarknetTypedData.Revision) throws {
            try XCTAssertThrowsError(makeTypedData(type, revision)) { error in
                XCTAssertEqual(error as? StarknetTypedDataError, .basicTypeRedefinition(type))
            }
        }
        func testPresetTypeRedifintion(_ type: String, _ revision: StarknetTypedData.Revision) throws {
            try XCTAssertThrowsError(makeTypedData(type, revision)) { error in
                XCTAssertEqual(error as? StarknetTypedDataError, .presetTypeRedefinition(type))
            }
        }

        let basicTypesV0 = [
            "felt", "bool", "string", "selector", "merkletree",
        ]
        let basicTypesV1 = basicTypesV0 + ["enum", "u128", "i128", "ContractAddress", "ClassHash", "timestamp", "shortstring"]
        let presetTypesV1 = ["u256", "TokenAmount", "NftId"]

        try XCTAssertNoThrow(makeTypedData("myType", .v0))
        try basicTypesV0.forEach { type in
            try testBasicTypeRedifintion(type, .v0)
        }
        try basicTypesV1.forEach { type in
            try testBasicTypeRedifintion(type, .v1)
        }
        try presetTypesV1.forEach { type in
            try testPresetTypeRedifintion(type, .v1)
        }
    }

    func testMissingDomainType() throws {
        try [StarknetTypedData.Revision.v0, .v1].forEach { revision in
            let (separatorName, domain) = switch revision {
            case .v0: (Self.domainTypeV0.0, Self.exampleDomainV0)
            case .v1: (Self.domainTypeV1.0, Self.exampleDomainV1)
            }

            try XCTAssertThrowsError(StarknetTypedData(types: [:], primaryType: "felt", domain: domain, message: "{}")) { error in
                XCTAssertEqual(error as? StarknetTypedDataError, .dependencyNotDefined(separatorName))
            }
        }
    }

    func testDanglingTypes() throws {
        try XCTAssertThrowsError(
            StarknetTypedData(types: [Self.domainTypeV1.0: Self.domainTypeV1.1, "danglingType": []], primaryType: "felt", domain: Self.exampleDomainV1, message: "{}")
        ) { error in
            XCTAssertEqual(error as? StarknetTypedDataError, .danglingType("danglingType"))
        }
    }

    func testMissingDependency() throws {
        let typedData = try StarknetTypedData(
            types: [
                Self.domainTypeV1.0: Self.domainTypeV1.1,
                "house": [StarknetTypedData.StandardType(name: "fridge", type: "ice cream")],
            ],
            primaryType: "house",
            domain: Self.exampleDomainV1,
            message: "{}"
        )

        XCTAssertThrowsError(
            try typedData.getStructHash(typeName: "house", data: "{\"fridge\": 1}")
        )
    }

    func testEncodeBool() throws {
        let cases: [(Any: Encodable, Felt)] = [(true, .one), (false, .zero), ("true", .one), ("false", .zero), ("0x1", .one), ("0x0", .zero), ("1", .one), ("0", .zero), (1, .one), (0, .zero)]

        for (input, expected) in cases {
            let element = try JSONDecoder().decode(StarknetTypedData.Element.self, from: JSONEncoder().encode(input))
            let encodedValue = try CasesRev1.td.encode(element: element, forType: "bool")

            XCTAssertEqual(encodedValue, expected)
        }
    }

    func testEncodeInvalidBool() throws {
        let cases: [any Encodable] = [2, "2", "0x123"]
        for input in cases {
            let element = try JSONDecoder().decode(StarknetTypedData.Element.self, from: JSONEncoder().encode(input))
            XCTAssertThrowsError(try CasesRev1.td.encode(element: element, forType: "bool")) { error in
                XCTAssertEqual(error as? StarknetTypedDataError, .invalidBool(element))
            }
        }
    }

    func testEncodeU128() throws {
        let cases: [(any Encodable, Felt)] = [
            (0, .zero),
            (1, .one),
            (1_000_000, 1_000_000),
            ("0x0", .zero),
            ("0x1", .one),
            ("0x3e8", 1000),
            ((BigUInt(2).power(128) - 1).description, Felt(BigUInt(2).power(128) - 1)!),
        ]

        for (input, expected) in cases {
            let element = try JSONDecoder().decode(StarknetTypedData.Element.self, from: JSONEncoder().encode(input))
            let encodedValue = try CasesRev1.td.encode(element: element, forType: "u128")

            XCTAssertEqual(encodedValue, expected)
        }
    }

    func testEncodeInvalidU128() throws {
        let cases: [any Encodable] = [
            -1,
            "-1",
            "0x" + String(BigUInt(2).power(128), radix: 16),
            (BigUInt(2).power(128) + 1).description,
        ]

        for input in cases {
            let element = try JSONDecoder().decode(StarknetTypedData.Element.self, from: JSONEncoder().encode(input))
            XCTAssertThrowsError(try CasesRev1.td.encode(element: element, forType: "u128")) { error in
                XCTAssertEqual(error as? StarknetTypedDataError, .invalidNumericValue(element))
            }
        }
    }

    func testEncodeI128() throws {
        let cases: [(any Encodable, Felt)] = [
            (0, .zero),
            (1, .one),
            (1_000_000, 1_000_000),
            ("0x0", .zero),
            ("0x1", .one),
            ("0x3e8", 1000),
            ((BigUInt(2).power(127) - 1).description, Felt(BigUInt(2).power(127) - 1)!),
            (-1, Felt(fromSigned: -1)!),
            (-1_000_000, Felt(fromSigned: -1_000_000)!),
            ("-1", Felt(fromSigned: -1)!),
            ((-BigInt(2).power(127)).description, Felt(fromSigned: -BigInt(2).power(127))!),
        ]

        for (input, expected) in cases {
            let element = try JSONDecoder().decode(StarknetTypedData.Element.self, from: JSONEncoder().encode(input))
            let encodedValue = try CasesRev1.td.encode(element: element, forType: "i128")

            XCTAssertEqual(encodedValue, expected)
        }
    }

    func testEncodeInvalidI128() throws {
        let cases: [any Encodable] = [
            (-BigInt(2).power(127) - 1).description,
            "0x" + String(BigUInt(2).power(127), radix: 16),
        ]

        for input in cases {
            let element = try JSONDecoder().decode(StarknetTypedData.Element.self, from: JSONEncoder().encode(input))
            XCTAssertThrowsError(try CasesRev1.td.encode(element: element, forType: "i128")) { error in
                XCTAssertEqual(error as? StarknetTypedDataError, .invalidNumericValue(element))
            }
        }
    }

    func testEncodeType() throws {
        let cases: [(StarknetTypedData, String, String)] =
            [
                (CasesRev0.td, "Mail", "Mail(from:Person,to:Person,contents:felt)Person(name:felt,wallet:felt)"),
                (CasesRev0.tdStructMerkleTree, "Session", "Session(key:felt,expires:felt,root:merkletree)"),
                (CasesRev1.td, "Mail", """
                "Mail"("from":"Person","to":"Person","contents":"felt")"Person"("name":"felt","wallet":"felt")
                """),
                (CasesRev1.tdBasicTypes, "Example", """
                "Example"("n0":"felt","n1":"bool","n2":"string","n3":"selector","n4":"u128","n5":"i128","n6":"ContractAddress","n7":"ClassHash","n8":"timestamp","n9":"shortstring")
                """),
                (CasesRev1.tdEnum, "Example", """
                "Example"("someEnum":"MyEnum")"MyEnum"("Variant 1":(),"Variant 2":("u128","u128*"),"Variant 3":("u128"))
                """),
                (CasesRev1.tdFeltMerkleTree, "Example", """
                "Example"("value":"felt","root":"merkletree")
                """),
            ]
        try cases.forEach { data, typeName, expectedResult in
            let encodedType = try data.encode(type: typeName)
            XCTAssertEqual(encodedType, expectedResult)
        }
    }

    func testTypeHashCalculation() throws {
        let cases: [(StarknetTypedData, String, Felt)] = [
            (Self.CasesRev0.td, "StarkNetDomain", "0x1bfc207425a47a5dfa1a50a4f5241203f50624ca5fdf5e18755765416b8e288"),
            (Self.CasesRev0.td, "Person", "0x2896dbe4b96a67110f454c01e5336edc5bbc3635537efd690f122f4809cc855"),
            (Self.CasesRev0.td, "Mail", "0x13d89452df9512bf750f539ba3001b945576243288137ddb6c788457d4b2f79"),
            (Self.CasesRev0.tdString, "String", "0x1933fe9de7e181d64298eecb44fc43b4cec344faa26968646761b7278df4ae2"),
            (Self.CasesRev0.tdString, "Mail", "0x1ac6f84a5d41cee97febb378ddabbe1390d4e8036df8f89dee194e613411b09"),
            (Self.CasesRev0.tdFeltArr, "Mail", "0x5b03497592c0d1fe2f3667b63099761714a895c7df96ec90a85d17bfc7a7a0"),
            (Self.CasesRev0.tdStructArr, "Post", "0x1d71e69bf476486b43cdcfaf5a85c00bb2d954c042b281040e513080388356d"),
            (Self.CasesRev0.tdStructArr, "Mail", "0x873b878e35e258fc99e3085d5aaad3a81a0c821f189c08b30def2cde55ff27"),
            (Self.CasesRev0.tdStructMerkleTree, "Session", "0x1aa0e1c56b45cf06a54534fa1707c54e520b842feb21d03b7deddb6f1e340c"),
            (Self.CasesRev0.tdStructMerkleTree, "Policy", "0x2f0026e78543f036f33e26a8f5891b88c58dc1e20cbbfaf0bb53274da6fa568"),
            (Self.CasesRev0.tdValidate, "Validate", "0x1fc17ee4903c000b1c8c6c1424136d4efc4759d1e83915e981b18bc1074a72d"),
            (Self.CasesRev0.tdValidate, "Airdrop", "0x37dcb14df3270824843bbbf50c72a724bcb303179dfcce56b653262cbb6957c"),
            (Self.CasesRev1.td, "StarknetDomain", "0x1ff2f602e42168014d405a94f75e8a93d640751d71d16311266e140d8b0a210"),
            (Self.CasesRev1.td, "Person", "0x30f7aa21b8d67cb04c30f962dd29b95ab320cb929c07d1605f5ace304dadf34"),
            (Self.CasesRev1.td, "Mail", "0x560430bf7a02939edd1a5c104e7b7a55bbab9f35928b1cf5c7c97de3a907bd"),
            (Self.CasesRev1.tdBasicTypes, "Example", "0x1f94cd0be8b4097a41486170fdf09a4cd23aefbc74bb2344718562994c2c111"),
            (Self.CasesRev1.tdPresetTypes, "Example", "0x1a25a8bb84b761090b1fadaebe762c4b679b0d8883d2bedda695ea340839a55"),
            (Self.CasesRev1.tdEnum, "Example", "0x380a54d417fb58913b904675d94a8a62e2abc3467f4b5439de0fd65fafdd1a8"),
            (Self.CasesRev1.tdFeltMerkleTree, "Example", "0x160b9c0e8a7c561f9c5d9e3cc2990a1b4d26e94aa319e9eb53e163cd06c71be"),
        ]

        try cases.forEach { data, typeName, expectedResult in
            let hash = try data.getTypeHash(typeName: typeName)

            XCTAssertEqual(hash, expectedResult)
        }
    }

    func testStructHashCalculation() throws {
        let cases: [(StarknetTypedData, String, String, Felt)] = [
            (
                Self.CasesRev0.td,
                "StarkNetDomain",
                "domain",
                "0x54833b121883a3e3aebff48ec08a962f5742e5f7b973469c1f8f4f55d470b07"
            ),
            (Self.CasesRev0.td, "Mail", "message", "0x4758f1ed5e7503120c228cbcaba626f61514559e9ef5ed653b0b885e0f38aec"),
            (
                Self.CasesRev0.tdString,
                "Mail",
                "message",
                "0x1d16b9b96f7cb7a55950b26cc8e01daa465f78938c47a09d5a066ca58f9936f"
            ),
            (
                Self.CasesRev0.tdFeltArr,
                "Mail",
                "message",
                "0x26186b02dddb59bf12114f771971b818f48fad83c373534abebaaa39b63a7ce"
            ),
            (
                Self.CasesRev0.tdStructArr,
                "Mail",
                "message",
                "0x5650ec45a42c4776a182159b9d33118a46860a6e6639bb8166ff71f3c41eaef"
            ),
            (
                Self.CasesRev0.tdStructMerkleTree,
                "Session",
                "message",
                "0x73602062421caf6ad2e942253debfad4584bff58930981364dcd378021defe8"
            ),
            (
                Self.CasesRev0.tdValidate,
                "Validate",
                "message",
                "0x389e55e4a3d36c6ba04f46f1021a695c934d6782eaf64e47ac059a06a2520c2"
            ),
            (
                Self.CasesRev1.td,
                "StarknetDomain",
                "domain",
                "0x555f72e550b308e50c1a4f8611483a174026c982a9893a05c185eeb85399657"
            ),
            (
                Self.CasesRev1.tdBasicTypes,
                "Example",
                "message",
                "0x391d09a51a31dd17f7270aaa9904688fbeeb9c56a7e2d15c5a6af32e981c730"
            ),
            (
                Self.CasesRev1.tdPresetTypes,
                "Example",
                "message",
                "0x74fba3f77f8a6111a9315bac313bf75ecfa46d1234e0fda60312fb6a6517667"
            ),
            (
                Self.CasesRev1.tdEnum,
                "Example",
                "message",
                "0x3d4384ff5cec32b86462e89f5a803b55ff0048c4f5a10ba9d6cd381317d9c3"
            ),
            (
                Self.CasesRev1.tdFeltMerkleTree,
                "Example",
                "message",
                "0x40ef40c56c0469799a916f0b7e3bc4f1bbf28bf659c53fb8c5ee4d8d1b4f5f0"
            ),
        ]

        try cases.forEach { data, typeName, dataSource, expectedResult in
            let hash = if dataSource == "domain" {
                try data.getStructHash(domain: data.domain)
            } else {
                try data.getStructHash(typeName: typeName, data: data.message)
            }

            XCTAssertEqual(hash, expectedResult)
        }
    }

    func testMessageHashCalculation() throws {
        let cases: [(StarknetTypedData, Felt, Felt)] = [
            (
                Self.CasesRev0.td,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x6fcff244f63e38b9d88b9e3378d44757710d1b244282b435cb472053c8d78d0"
            ),
            (
                Self.CasesRev0.tdString,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x691b977ee0ee645647336f01d724274731f544ad0d626b078033d2541ee641d"
            ),
            (
                Self.CasesRev0.tdFeltArr,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x30ab43ef724b08c3b0a9bbe425e47c6173470be75d1d4c55fd5bf9309896bce"
            ),
            (
                Self.CasesRev0.tdStructArr,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x5914ed2764eca2e6a41eb037feefd3d2e33d9af6225a9e7fe31ac943ff712c"
            ),
            (
                Self.CasesRev0.tdStructMerkleTree,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x5d28fa1b31f92e63022f7d85271606e52bed89c046c925f16b09e644dc99794"
            ),
            (
                Self.CasesRev0.tdValidate,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x3b3fbdb1961ae09cb5b2716b07142e63930fb2eddc4842641ca1df7352766a1"
            ),
            (
                Self.CasesRev1.td,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x7f6e8c3d8965b5535f5cc68f837c04e3bbe568535b71aa6c621ddfb188932b8"
            ),
            (
                Self.CasesRev1.tdBasicTypes,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x2d80b87b8bc32068247c779b2ef0f15f65c9c449325e44a9df480fb01eb43ec"
            ),
            (
                Self.CasesRev1.tdPresetTypes,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x185b339d5c566a883561a88fb36da301051e2c0225deb325c91bb7aa2f3473a"
            ),
            (
                Self.CasesRev1.tdEnum,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x3df10475ad5a8f49db4345a04a5b09164d2e24b09f6e1e236bc1ccd87627cc"
            ),
            (
                Self.CasesRev1.tdFeltMerkleTree,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x4f706783e0d7d0e61433d41343a248a213e9ab341d50ba978dfc055f26484c9"
            ),
        ]

        try cases.forEach { data, address, expectedResult in
            let hash = try data.getMessageHash(accountAddress: address)

            XCTAssertEqual(hash, expectedResult)
        }
    }

    func testEncodingTimestamp() throws {
        let tdJsonStr = try loadTypedDataJsonStringFromFile(name: "typed_data_rev_1_timestamp_example")
        guard let tdEncodedContents = tdJsonStr.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Failed to load typed data"))
        }

        do {
            let td = try JSONDecoder().decode(StarknetTypedData.self, from: tdEncodedContents)
            let tdEncoded = try JSONEncoder().encode(td)
            let originalJson = try JSONSerialization.jsonObject(with: tdEncodedContents, options: []) as? [String: Any]
            let encodedJson = try JSONSerialization.jsonObject(with: tdEncoded, options: []) as? [String: Any]

            XCTAssertEqual(originalJson as NSDictionary?, encodedJson as NSDictionary?)
        } catch let e {
            throw e
        }
    }
}
