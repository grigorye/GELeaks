//
//  ReportedLeaksTests.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import XCTest

class ReportedLeaksTests : LeaksReportsTestCaseBase, LeaksSanityTesting {

	func testLeaking() {
		guard testingLeaksSanity else {
			return
		}

		_Self.leakingTestRunCount += 1
		
		let retainCycledArray = NSMutableArray()
		let leakedObject = LeaksSanityTestsLeakedObject()
		retainCycledArray.add(retainCycledArray)
		retainCycledArray.add(leakedObject)
	}

	class func assertSanity(for config: LeakDetectionConfig) {
		XCTAssertEqual(_Self.leakingTestRunCount, config.preheatCount + config.randomCount)
		XCTAssertEqual(_Self.likelyLeaksReported.count, 1)
	}
	
	// MARK: -
	
	private static var classDataImp = ClassData()
	override class var _Self: ClassData {
		return classDataImp
	}
}

class LeaksSanityTestsLeakedObject : NSObject {
}
