//
//  NonReportedLeaksSanityTests.swift
//  GELeaks
//
//  Created by Grigory Entin on 08/12/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest

class NonReportedLeaksTests : LeaksSanityTestsBase, LeaksSanityTesting {
	
	func testSanity() {
		// This won't be reported as a leak as it doesn't use +alloc[WithZone:].
		let x = NSMutableArray()
		x.add(x)
	}
	
	class func didTestLeaks(for selector: Selector) {
		XCTAssertEqual(_Self.likelyLeaksReported.count, 0)
	}
	
	// MARK: -
	
	class var _Self: LeaksSanityReportsClassState {
		return classStateImp
	}
	private static var classStateImp = LeaksSanityReportsClassState()
}
