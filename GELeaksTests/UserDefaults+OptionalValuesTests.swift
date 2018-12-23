//
//  UserDefaults+OptionalValuesTests.swift
//  GELeaksTests
//
//  Created by Grigory Entin on 23/12/2018.
//

@testable import GELeaks
import XCTest

class UserDefaults_OptionalValuesTests : XCTestCase {
	
	func testOptionalBoolWithoutValue() {
		XCTAssertNil(me.bool(forKey: "foo"))
	}
	
	func testOptionalBoolWithValue() {
		fakeUserDefaults.object = true
		XCTAssertEqual(Optional(true), me.bool(forKey: "foo"))
	}
	
	func testOptionalIntegerWithoutValue() {
		XCTAssertNil(me.integer(forKey: "foo"))
	}
	
	func testOptionalIntegerWithValue() {
		fakeUserDefaults.object = 2
		XCTAssertEqual(Optional(2), me.integer(forKey: "foo"))
	}
	
	func testFakeInitialValues() {
		XCTAssertNil(fakeUserDefaults.object(forKey: "foo"))
		XCTAssertEqual(false, fakeUserDefaults.bool(forKey: "foo"))
		XCTAssertEqual(0, fakeUserDefaults.integer(forKey: "foo"))
	}
	
	func testFakeBool() {
		fakeUserDefaults.object = true
		XCTAssertEqual(true, fakeUserDefaults.bool(forKey: "foo"))
	}

	func testFakeInteger() {
		fakeUserDefaults.object = 2
		XCTAssertEqual(2, fakeUserDefaults.integer(forKey: "foo"))
	}

	private var me: UserDefaults_Nonoptional {
		return fakeUserDefaults
	}
	
	private var fakeUserDefaults = FakeUserDefaults()
}

private struct FakeUserDefaults : UserDefaults_Nonoptional {
	
	var object: Any?

	func bool(forKey defaultName: String) -> Bool {
		return (object as? Bool) ?? false
	}
	
	func integer(forKey defaultName: String) -> Int {
		return (object as? Int) ?? 0
	}
	
	func object(forKey defaultName: String) -> Any? {
		return object
	}
}
