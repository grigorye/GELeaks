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
		let a = NSMutableArray()
		a.add(DummyObject())
		#if false
		a.add(a)
		#endif
	}
	
	func testMoreDummy() {
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
