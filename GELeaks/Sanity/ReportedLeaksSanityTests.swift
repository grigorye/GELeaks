//
//  ReportedLeaksSanityTests.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import XCTest

class ReportedLeaksTests : LeaksSanityTestsBase, LeaksSanityTesting {
	
	func testSanity() {
		let retainCycledArray = NSMutableArray()
		let leakedObject = LeaksSanityTestsLeakedObject()
		retainCycledArray.add(retainCycledArray)
		retainCycledArray.add(leakedObject)
	}
	
	override class func didTestLeaks(for selector: Selector, config: LeakDetectionConfig) {
		XCTAssertEqual(_Self.likelyLeaksReported.count, 1)
		super.didTestLeaks(for: selector, config: config)
	}
	
	// MARK: -
	
	class var _Self: LeaksSanityReportsClassState {
		return classStateImp
	}
	private static var classStateImp = LeaksSanityReportsClassState()
}

class LeaksSanityTestsLeakedObject : NSObject {
}
