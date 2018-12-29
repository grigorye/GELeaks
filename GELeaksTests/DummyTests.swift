//
//  DummyTests.swift
//  GELeaks
//
//  Created by Grigory Entin on 20/12/2018.
//

import XCTest

class DummyTests : XCTestCase {
	
	private let dummyProperty = DummyProperty()
	
	func testDummy() {
		leakAsNecessary()
	}
	
	func testMoreDummy() {
	}
	
	/// When enabled, triggers a failure that is expected to be handled without a problem.
	func notestWaiter() {
		let expectation = self.expectation(description: "foo")
		wait(for: [expectation], timeout: 0.01)
	}
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	deinit {()}
}

class DummyObject : NSObject {
	
	override init() {
		super.init()
	}
	
	deinit {()}
}

class DummyProperty : NSObject {
	
	override init() {
		super.init()
	}
	
	deinit {()}
}

func leakAsNecessary() {
	let a = NSMutableArray()
	a.add(DummyObject())
	#if false
	a.add(a)
	#endif
}
