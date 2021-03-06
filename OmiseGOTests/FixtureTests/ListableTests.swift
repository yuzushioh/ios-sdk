//
//  ListableTests.swift
//  OmiseGOTests
//
//  Created by Mederic Petit on 7/3/18.
//  Copyright © 2017-2018 Omise Go Pte. Ltd. All rights reserved.
//

import XCTest
import OmiseGO

class ListableTests: FixtureTestCase {

    func testListableFailure() {
        let expectation = self.expectation(description: "Fails to load the response for this dummy object")
        ListableDummy.list(using: self.testCustomClient) { (response) in
            defer { expectation.fulfill() }
            switch response {
            case .success(data: _): XCTFail("Shouldn't succeed")
            case .fail(error: let error):
                XCTAssertEqual(error.message, "error_message")
            }
        }
        waitForExpectations(timeout: 15.0, handler: nil)
    }

    func testPaginatedListableFailure() {
        let expectation = self.expectation(description: "Fails to load the response for this paginated dummy object")
        PaginatedListableDummy.list(using: self.testCustomClient) { (response) in
            defer { expectation.fulfill() }
            switch response {
            case .success(data: _): XCTFail("Shouldn't succeed")
            case .fail(error: let error):
                XCTAssertEqual(error.message, "error_message")
            }
        }
        waitForExpectations(timeout: 15.0, handler: nil)
    }
}
