//
//  XCTestCase+Leaks.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import FBAllocationTracker
import XCTest

struct LeakDetectionConfig {
	let preheatCount: Int
	let randomCount: Int
	
	let reportLeak: (_ testCaseClass: AnyClass, _ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig) -> Void
}

func defaultReportLeak(_ testCaseClass: AnyClass, _ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig) {
	let leakedCls: AnyClass = NSClassFromString(allocationSummary.className)!
	if allocationSummary.aliveObjects % config.randomCount == 0 {
		let times = allocationSummary.aliveObjects / config.randomCount
		XCTFail("\(testCaseClass).\(selector): \(leakedCls) is likely leaked (or left retained after the completion) \(times) times.")
	} else {
		print("\(testCaseClass).\(selector): \(leakedCls) is potentially leaked.")
	}
}

extension XCTestCase {
	
	class func testLeaks(for method: Method, config: LeakDetectionConfig) {
		let selector = method_getName(method)
		let methodName = NSStringFromSelector(selector)
		guard methodName.hasPrefix("test"), !methodName.hasSuffix(":") else {
			return
		}
		let cls = self
		let exception = NSException.catch({
			self.testLeaks(selector: selector, config: config)
		})
		if let exception = exception {
			print("\(cls).\(methodName): Caught \(exception).")
		}
	}
	
	class func testLeaks(selector: Selector, config: LeakDetectionConfig) {
		let invokeTest = {
			autoreleasepool {
				let c = self.init(selector: selector)
				c.invokeTest()
			}
		}
		
		for _ in 0 ..< config.preheatCount {
			invokeTest()
		}
		let allocationTrackerManager = FBAllocationTrackerManager.shared()!
		allocationTrackerManager.startTrackingAllocations()
		for _ in 0 ..< config.randomCount {
			invokeTest()
		}
		let allocationSummary = allocationTrackerManager.currentAllocationSummary()
		allocationTrackerManager.stopTrackingAllocations()
		for i in allocationSummary ?? [] where i.aliveObjects >= 0 {
			let cls: AnyClass = NSClassFromString(i.className)!
			#if false
			let bundle = Bundle(for: cls)
			let bundlePath = bundle.bundlePath
			if bundlePath.hasPrefix("/System/") || bundlePath.hasPrefix("/Applications/") || bundlePath.hasPrefix("/Library/"){
				continue
			}
			#endif
			config.reportLeak(self, selector, i, config)
		}
	}
}
