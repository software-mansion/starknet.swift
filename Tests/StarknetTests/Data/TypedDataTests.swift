//
//  TypedDataTests.swift
//
//
//  Created by Bartosz Rybarski on 14/02/2023.
//

import Starknet
import XCTest

final class TypedDataTests: XCTestCase {
    func loadTypedDataFromFile(name: String) -> TypedData? {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json"),
              let contents = try? String(contentsOf: url),
              let contentsData = contents.data(using: .utf8)
        else {
            return nil
        }

        return try? JSONDecoder().decode(TypedData.self, from: contentsData)
    }

    func testTypedDataDecoding() {
        XCTAssertNotNil(loadTypedDataFromFile(name: "typed_data_example"))
        XCTAssertNotNil(loadTypedDataFromFile(name: "typed_data_felt_array_example"))
        XCTAssertNotNil(loadTypedDataFromFile(name: "typed_data_long_string_example"))
        XCTAssertNotNil(loadTypedDataFromFile(name: "typed_data_struct_array_example"))
    }
}
