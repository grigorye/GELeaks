//
//  Reporting.swift
//  Pods
//
//  Created by Grigory Entin on 22/12/2018.
//

import FBAllocationTracker
import XCTest
import Foundation

func defaultReportLeak(_ testCaseClass: AnyClass, _ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig) {
	if let leaksReportsTestCaseClass = testCaseClass as? LeaksSanityTestsBase.Type {
		leaksReportsTestCaseClass.reportLeak(selector, allocationSummary, config)
		return
	}
	let leakedCls: AnyClass = NSClassFromString(allocationSummary.className)!
	if allocationSummary.aliveObjects % config.randomCount == 0 {
		let times = allocationSummary.aliveObjects / config.randomCount
		XCTFail("\(testCaseClass).\(selector): \(leakedCls) is likely leaked (or left retained after the completion) \(times) times.")
	} else {
		print("\(testCaseClass).\(selector): \(leakedCls) is potentially leaked.")
	}
}
