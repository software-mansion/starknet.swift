//
//  TypedDataTests.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//

import Starknet
import XCTest

final class TypedDataTests: XCTestCase {
    static let td = loadTypedDataFromFile(name: "typed_data_example")!
    static let tdFeltArr = loadTypedDataFromFile(name: "typed_data_felt_array_example")!
    static let tdString = loadTypedDataFromFile(name: "typed_data_long_string_example")!
    static let tdStructArr = loadTypedDataFromFile(name: "typed_data_struct_array_example")!
    static let tdValidate = loadTypedDataFromFile(name: "typed_data_validate_example")!

    func testInvalidTypes() {
        func testInvalidType(_ type: String) {
            XCTAssertNil(
                StarknetTypedData(types: [type: []], primaryType: type, domain: "{}", message: "{\"\(type)\": 1}")
            )
        }

        testInvalidType("felt")
        testInvalidType("felt*")
        testInvalidType("string")
        testInvalidType("selector")
    }

    func testMissingDependency() {
        let typedData = StarknetTypedData(
            types: ["house": [StarknetTypedData.TypeDeclaration(name: "fridge", type: "ice cream")]],
            primaryType: "felt",
            domain: "{}",
            message: "{}"
        )

        XCTAssertThrowsError(
            try typedData?.getStructHash(typeName: "house", data: "{\"fridge\": 1}")
        )
    }

    func testTypeHashCalculation() throws {
        let cases: [(StarknetTypedData, String, Felt)] = [
            (Self.td, "StarkNetDomain", "0x1bfc207425a47a5dfa1a50a4f5241203f50624ca5fdf5e18755765416b8e288"),
            (Self.td, "Person", "0x2896dbe4b96a67110f454c01e5336edc5bbc3635537efd690f122f4809cc855"),
            (Self.td, "Mail", "0x13d89452df9512bf750f539ba3001b945576243288137ddb6c788457d4b2f79"),
            (Self.tdString, "String", "0x1933fe9de7e181d64298eecb44fc43b4cec344faa26968646761b7278df4ae2"),
            (Self.tdString, "Mail", "0x1ac6f84a5d41cee97febb378ddabbe1390d4e8036df8f89dee194e613411b09"),
            (Self.tdFeltArr, "Mail", "0x5b03497592c0d1fe2f3667b63099761714a895c7df96ec90a85d17bfc7a7a0"),
            (Self.tdStructArr, "Post", "0x1d71e69bf476486b43cdcfaf5a85c00bb2d954c042b281040e513080388356d"),
            (Self.tdStructArr, "Mail", "0x873b878e35e258fc99e3085d5aaad3a81a0c821f189c08b30def2cde55ff27"),
            (Self.tdValidate, "Validate", "0x2e86ac4735e6012fbeaa68cbd0e5a089014d0da150fa915769a35d5eba30593"),
        ]

        try cases.forEach { data, typeName, expectedResult in
            let hash = try data.getTypeHash(typeName: typeName)

            XCTAssertEqual(hash, expectedResult)
        }
    }

    func testStructHashCalculation() throws {
        let cases: [(StarknetTypedData, String, String, Felt)] = [
            (
                Self.td,
                "StarkNetDomain",
                "domain",
                "0x54833b121883a3e3aebff48ec08a962f5742e5f7b973469c1f8f4f55d470b07"
            ),
            (Self.td, "Mail", "message", "0x4758f1ed5e7503120c228cbcaba626f61514559e9ef5ed653b0b885e0f38aec"),
            (
                Self.tdString,
                "Mail",
                "message",
                "0x1d16b9b96f7cb7a55950b26cc8e01daa465f78938c47a09d5a066ca58f9936f"
            ),
            (
                Self.tdFeltArr,
                "Mail",
                "message",
                "0x26186b02dddb59bf12114f771971b818f48fad83c373534abebaaa39b63a7ce"
            ),
            (
                Self.tdStructArr,
                "Mail",
                "message",
                "0x5650ec45a42c4776a182159b9d33118a46860a6e6639bb8166ff71f3c41eaef"
            ),
            (
                Self.tdValidate,
                "Validate",
                "message",
                "0x87ecd5622070667d2534fa83dd9b16f6cb497b42998d301e8df0ed5875d02d"
            ),
        ]

        try cases.forEach { data, typeName, dataSource, expectedResult in
            let dataStruct = dataSource == "domain" ? data.domain : data.message

            let hash = try data.getStructHash(typeName: typeName, data: dataStruct)

            XCTAssertEqual(hash, expectedResult)
        }
    }

    func testMessageHashCalculation() throws {
        let cases: [(StarknetTypedData, Felt, Felt)] = [
            (
                Self.td,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x6fcff244f63e38b9d88b9e3378d44757710d1b244282b435cb472053c8d78d0"
            ),
            (
                Self.tdString,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x691b977ee0ee645647336f01d724274731f544ad0d626b078033d2541ee641d"
            ),
            (
                Self.tdFeltArr,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x30ab43ef724b08c3b0a9bbe425e47c6173470be75d1d4c55fd5bf9309896bce"
            ),
            (
                Self.tdStructArr,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x5914ed2764eca2e6a41eb037feefd3d2e33d9af6225a9e7fe31ac943ff712c"
            ),
            (
                Self.tdValidate,
                "0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826",
                "0x28e38c1c65783abb40b871705095584b96bcbf1f80c8268a0659d074b3afd92"
            ),
        ]

        try cases.forEach { data, address, expectedResult in
            let hash = try data.getMessageHash(accountAddress: address)

            XCTAssertEqual(hash, expectedResult)
        }
    }
}
