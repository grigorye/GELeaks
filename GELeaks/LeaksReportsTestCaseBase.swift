//
//  LeaksReportsTestCaseBase.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import FBAllocationTracker
import XCTest

class LeaksReportsTestCaseBase : XCTestCase {
	
	class func reportLeak(_ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig) {
		if allocationSummary.aliveObjects % config.randomCount == 0 {
			_Self.likelyLeaksReported += [(selector, allocationSummary, config)]
		} else {
			_Self.potentialLeaksReported += [(selector, allocationSummary, config)]
		}
	}
	
	// MARK: -
	
	class ClassData {
		var leakingTestRunCount: Int = 0
		
		var likelyLeaksReported: [(Selector, FBAllocationTrackerSummary, LeakDetectionConfig)] = []
		var potentialLeaksReported: [(Selector, FBAllocationTrackerSummary, LeakDetectionConfig)] = []
	}
	
	class var _Self: ClassData {
		fatalError()
	}
	var _Self: ClassData {
		return type(of: self)._Self
	}
}
