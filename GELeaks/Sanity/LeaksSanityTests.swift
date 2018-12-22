//
//  LeaksSanityTests.swift
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import FBAllocationTracker
import XCTest

// A protocol for handling sanity tests like no other tests.
protocol LeaksSanityTesting : class {
	
	static func reportLeak(_ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig)
	static func assertSanity(for config: LeakDetectionConfig)
}

private var sanityTestCaseClasses: [(XCTestCase & LeaksSanityTesting).Type] = {
	return Bundle(for: LeaksSanityTests.self).allClasses().compactMap { $0 as? (XCTestCase & LeaksSanityTesting).Type }
}()

class LeaksSanityTests : XCTestCase {
	
	override class var defaultTestSuite: XCTestSuite {
		let suite = XCTestSuite(forTestCaseClass: self)
		sanityTestCaseClasses.forEach {
			suite.addTest(XCTestSuite(forTestCaseClass: $0))
		}
		return suite
	}
	
	override func setUp() {
		XCTAssert(!testingLeaksSanity)

		super.setUp()
		
		testingLeaksSanity = true
	}
	
	override func tearDown() {
		XCTAssert(testingLeaksSanity)
		
		let config = LeakDetectionConfig(reportLeak: { (testCaseClass, selector, allocationSummary, config) in
			let leaksSanityTests = testCaseClass as! LeaksSanityTesting.Type
			leaksSanityTests.reportLeak(selector, allocationSummary, config)
		})
		sanityTestCaseClasses.forEach {
			$0.assertSanity(for: config)
		}
		
		super.tearDown()

		testingLeaksSanity = false
	}
}
