//
//  NonReportedLeaksTests.swift
//  GELeaks
//
//  Created by Grigory Entin on 08/12/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest

class NonReportedLeaksTests : LeaksReportsTestCaseBase, LeaksSanityTesting {

	func testLeaking() {
		guard testingLeaksSanity else {
			return
		}
		
		_Self.leakingTestRunCount += 1

		// This won't be reported as a leak as it doesn't use +alloc[WithZone:].
		let x = NSMutableArray()
		x.add(x)
	}
	
	class func assertSanity(for config: LeakDetectionConfig) {
		XCTAssertEqual(_Self.leakingTestRunCount, config.preheatCount + config.randomCount)
		XCTAssertEqual(_Self.likelyLeaksReported.count, 0)
	}
	
	// MARK: -
	
	private static var classDataImp = ClassData()
	override class var _Self: ClassData {
		return classDataImp
	}
}
