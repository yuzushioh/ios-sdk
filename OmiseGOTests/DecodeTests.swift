//
//  DecodeTests.swift
//  OmiseGOTests
//
//  Created by Mederic Petit on 13/11/2560 BE.
//  Copyright © 2560 OmiseGO. All rights reserved.
//

import XCTest
@testable import OmiseGO

class DecodeTests: XCTestCase {

    func jsonData(withFileName name: String) throws -> Data {
        let bundle = Bundle(for: FixtureClient.self)
        let directoryURL = bundle.url(forResource: "Fixtures/objects", withExtension: nil)!
        let filePath = (name as NSString).appendingPathExtension("json")! as String
        let fixtureFileURL = directoryURL.appendingPathComponent(filePath)
        return try Data(contentsOf: fixtureFileURL)
    }

    func testMetadaDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "metadata")
            let decodedData =  try JSONDecoder().decode(MetadataDummy.self, from: jsonData)
            guard let metadata = decodedData.metadata else {
                XCTFail("Failed to decode metadata")
                return
            }
            XCTAssertEqual(metadata["a_string"] as? String, "some_string")
            XCTAssertEqual(metadata["an_integer"] as? Int, 1)
            XCTAssertEqual(metadata["a_bool"] as? Bool, true)
            XCTAssertEqual(metadata["a_double"] as? Double, 12.34)
            guard let object: [String: Any] = metadata["an_object"] as? [String: Any] else {
                XCTFail("could not decode object")
                return
            }
            XCTAssertEqual(object["a_key"] as? String, "a_value")
            guard let nestedObject: [String: Any] = object["a_nested_object"] as? [String: Any] else {
                XCTFail("Could not decode nested object")
                return
            }
            XCTAssertEqual(nestedObject["a_nested_key"] as? String, "a_nested_value")
            guard let array: [Any] = metadata["an_array"] as? [Any] else {
                XCTFail("Could not decode array")
                return
            }
            XCTAssertTrue(array.count == 2)
            XCTAssertEqual(array[0] as? String, "value_1")
            XCTAssertEqual(array[1] as? String, "value_2")
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testMetadaNullDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "metadata_null")
            let decodedData =  try JSONDecoder().decode(MetadataDummy.self, from: jsonData)
            XCTAssertEqual(decodedData.metadata!.count, 0)
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testJSONResponseDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "json_response")
            let decodedData =  try JSONDecoder().decode(OMGJSONResponse<[String: String]>.self, from: jsonData)
            XCTAssertEqual(decodedData.version, "1")
            XCTAssertEqual(decodedData.success, true)
            switch decodedData.data {
            case .success(data: let content):
                XCTAssertEqual(content["a_key"], "a_value")
            case .fail(error: let error):
                XCTFail(error.localizedDescription)
            }
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testJSONListReponseDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "json_list_response")
            let decodedData =
                try JSONDecoder().decode(OMGJSONResponse<OMGJSONListResponse<String>>.self, from: jsonData)
            XCTAssertEqual(decodedData.version, "1")
            XCTAssertEqual(decodedData.success, true)
            switch decodedData.data {
            case .success(data: let list):
                XCTAssertTrue(list.count == 2)
                XCTAssertEqual(list[0], "value_1")
                XCTAssertEqual(list[1], "value_2")
                XCTAssertEqual(list.startIndex, 0)
                XCTAssertEqual(list.endIndex, 2)
                XCTAssertEqual(list[0...1], ["value_1", "value_2"])
            case .fail(error: let error):
                XCTFail(error.localizedDescription)
            }
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testUserDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "user")
            let decodedData = try JSONDecoder().decode(User.self, from: jsonData)
            XCTAssertEqual(decodedData.id, "cec34607-0761-4a59-8357-18963e42a1aa")
            XCTAssertEqual(decodedData.providerUserId, "wijf-fbancomw-dqwjudb")
            XCTAssertEqual(decodedData.username, "john.doe@example.com")
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testMintedTokenDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "minted_token")
            let decodedData = try JSONDecoder().decode(MintedToken.self, from: jsonData)
            XCTAssertEqual(decodedData.id, "OMG:123")
            XCTAssertEqual(decodedData.symbol, "OMG")
            XCTAssertEqual(decodedData.name, "OmiseGO")
            XCTAssertEqual(decodedData.subUnitToUnit, 100000000)
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testSettingDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "setting")
            let decodedData = try JSONDecoder().decode(Setting.self, from: jsonData)
            XCTAssertTrue(decodedData.mintedTokens.count == 1)
            XCTAssertEqual(decodedData.mintedTokens[0].id, "OMG:123")
            XCTAssertEqual(decodedData.mintedTokens[0].symbol, "OMG")
            XCTAssertEqual(decodedData.mintedTokens[0].name, "OmiseGO")
            XCTAssertEqual(decodedData.mintedTokens[0].subUnitToUnit, 100000000)
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testBalanceDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "balance")
            let decodedData = try JSONDecoder().decode(Balance.self, from: jsonData)
            XCTAssertEqual(decodedData.amount, 103100)
            XCTAssertEqual(decodedData.mintedToken.id, "OMG:123")
            XCTAssertEqual(decodedData.mintedToken.symbol, "OMG")
            XCTAssertEqual(decodedData.mintedToken.name, "OmiseGO")
            XCTAssertEqual(decodedData.mintedToken.subUnitToUnit, 10000)
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testAddressDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "address")
            let decodedData = try JSONDecoder().decode(Address.self, from: jsonData)
            XCTAssertEqual(decodedData.address, "2c2e0f2e-fa0f-4abe-8516-9e92cf003486")
            XCTAssertTrue(decodedData.balances.count == 1)
            XCTAssertEqual(decodedData.balances[0].amount, 103100)
            XCTAssertEqual(decodedData.balances[0].mintedToken.id, "OMG:123")
            XCTAssertEqual(decodedData.balances[0].mintedToken.symbol, "OMG")
            XCTAssertEqual(decodedData.balances[0].mintedToken.name, "OmiseGO")
            XCTAssertEqual(decodedData.balances[0].mintedToken.subUnitToUnit, 10000)
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testAPIErrorDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "api_error")
            let decodedData = try JSONDecoder().decode(APIError.self, from: jsonData)
            XCTAssertEqual(decodedData.description, "Invalid parameters")
            switch decodedData.code {
            case .invalidParameters: XCTAssertTrue(true)
            default: XCTFail("Failed to decode the error code")
            }
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testTransactionRequestDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "transaction_request")
            let decodedData = try JSONDecoder().decode(TransactionRequest.self, from: jsonData)
            XCTAssertEqual(decodedData.id, "8eb0160e-1c96-481a-88e1-899399cc84dc")
            XCTAssertEqual(decodedData.mintedTokenId, "BTC:861020af-17b6-49ee-a0cb-661a4d2d1f95")
            XCTAssertEqual(decodedData.amount, 1337)
            XCTAssertEqual(decodedData.address, "3b7f1c68-e3bd-4f8f-9916-4af19be95d00")
            XCTAssertEqual(decodedData.correlationId, "31009545-db10-4287-82f4-afb46d9741d8")
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

    func testTransactionConsumeDecoding() {
        do {
            let jsonData = try self.jsonData(withFileName: "transaction_consume")
            let decodedData = try JSONDecoder().decode(TransactionConsume.self, from: jsonData)
            XCTAssertEqual(decodedData.id, "8eb0160e-1c96-481a-88e1-899399cc84dc")
            XCTAssertEqual(decodedData.status, .confirmed)
            XCTAssertEqual(decodedData.amount, 1337)
            let mintedToken = decodedData.mintedToken
            XCTAssertEqual(mintedToken.id, "BTC:123")
            XCTAssertEqual(mintedToken.symbol, "BTC")
            XCTAssertEqual(mintedToken.name, "Bitcoin")
            XCTAssertEqual(mintedToken.subUnitToUnit, 100000)
            XCTAssertEqual(decodedData.correlationId, "31009545-db10-4287-82f4-afb46d9741d8")
            XCTAssertEqual(decodedData.idempotencyToken, "31009545-db10-4287-82f4-afb46d9741d8")
            XCTAssertEqual(decodedData.transferId, "6ca40f34-6eaa-43e1-b2e1-a94ff3660988")
            XCTAssertEqual(decodedData.userId, "6f56efa1-caf9-4348-8e0f-f5af283f17ee")
            XCTAssertEqual(decodedData.transactionRequestId, "907056a4-fc2d-47cb-af19-5e73aade7ece")
            XCTAssertEqual(decodedData.address, "3b7f1c68-e3bd-4f8f-9916-4af19be95d00")
        } catch let thrownError {
            XCTFail(thrownError.localizedDescription)
        }
    }

}