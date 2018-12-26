//
//  LeaksSanityTestsBase.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import FBAllocationTracker
import XCTest

class LeaksSanityTestsBase : XCTestCase {
	
	override func tearDown() {
		_Self.leakingTestRunCount += 1
		super.tearDown()
	}
	
	class func didTestLeaks(for selector: Selector, config: LeakDetectionConfig) {
		XCTAssert(_Self.leakingTestRunCount >= (config.preheatCount + config.randomCount))
	}
	
	class func reportLeak(_ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig) {
		if allocationSummary.aliveObjects % config.randomCount == 0 {
			_Self.likelyLeaksReported += [(selector, allocationSummary, config)]
		} else {
			_Self.potentialLeaksReported += [(selector, allocationSummary, config)]
		}
	}
	
	// MARK: -
	
	var _Self: LeaksSanityReportsClassState {
		return type(of: self)._Self
	}
	
	private class var _Self: LeaksSanityReportsClassState {
		return (self as! LeaksSanityTesting.Type)._Self
	}
}

class LeaksSanityReportsClassState {
	
	var leakingTestRunCount: Int = 0
	
	var likelyLeaksReported: [(Selector, FBAllocationTrackerSummary, LeakDetectionConfig)] = []
	var potentialLeaksReported: [(Selector, FBAllocationTrackerSummary, LeakDetectionConfig)] = []
}
