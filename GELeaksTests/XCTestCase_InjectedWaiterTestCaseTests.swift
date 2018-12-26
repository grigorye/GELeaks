//
//  XCTestCase_InjectedWaiterTestCaseTests.swift
//  Pods
//
//  Created by Grigorii Entin on 12/26/18.
//

@testable import GELeaks
import XCTest

class XCTestCase_InjectedWaiterTestCaseTests : XCTestCase {
	
	func testNotInjected() {
		let test = type(of: self).nonLeakingTest(with: #selector(testNotInjected))
		XCTAssertNil(test.injectedWaiterTestCase)
	}
	
	func testInjected() {
		let test = type(of: self).nonLeakingTest(with: #selector(testNotInjected))
		XCTAssertNil(test.injectedWaiterTestCase)
		test.injectedWaiterTestCase = self
		XCTAssertEqual(test.injectedWaiterTestCase, self)
		test.injectedWaiterTestCase = nil
		XCTAssertNil(test.injectedWaiterTestCase)
	}
}
