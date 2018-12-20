//
//  LeaksSanityTesting.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import FBAllocationTracker
import XCTest

protocol LeaksSanityTesting : class {
	
	static func reportLeak(_ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig)
	static func assertSanity(for config: LeakDetectionConfig)
}
