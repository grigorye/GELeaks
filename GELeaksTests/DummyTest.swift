//
//  DummyTest.swift
//  GELeaks
//
//  Created by Grigory Entin on 20/12/2018.
//

import XCTest

class DummyTest : XCTestCase {
	
	func testDummy() {
		let a = NSMutableArray()
		a.add(DummyObject())
		#if false
		a.add(a)
		#endif
	}
}

class DummyObject : NSObject {}
