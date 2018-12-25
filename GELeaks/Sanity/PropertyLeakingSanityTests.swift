//
//  PropertyLeakingSanityTests.swift
//  GELeaks-iOS-Unit-Tests
//
//  Created by Grigorii Entin on 12/24/18.
//

import XCTest

class PropertyLeakingSanityTests : LeaksReportsTestCaseBase, LeaksSanityTesting {
	
	let x = LeaksSanityTestsLeakedObject()
	
	func testSanity() {}
	
	override class func didTestLeaks(for selector: Selector, config: LeakDetectionConfig) {
		XCTAssertEqual(_Self.likelyLeaksReported.count, 0)
		super.didTestLeaks(for: selector, config: config)
	}
	
	// MARK: -
	
	class var _Self: LeaksSanityReportsClassState {
		return classStateImp
	}
	private static var classStateImp = LeaksSanityReportsClassState()
}
