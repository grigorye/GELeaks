//
//  XCTestCase+Leaks.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import FBAllocationTracker
import XCTest


extension XCTestCase {
	
	class func testLeaks(for method: Method, config: LeakDetectionConfig, leaksTestCase: XCTestCase) {
		let selector = method_getName(method)
		let methodName = NSStringFromSelector(selector)
		guard methodName.hasPrefix("test"), !methodName.hasSuffix(":") else {
			return
		}
		let cls = self
		let exception = NSException.catch({
			self.testLeaks(selector: selector, config: config, leaksTestCase: leaksTestCase)
		})
		if let exception = exception {
			print("\(cls).\(methodName): Caught \(exception).")
		}
	}
	
	class func testLeaks(selector: Selector, config: LeakDetectionConfig, leaksTestCase: XCTestCase) {
		let performTest = {
			autoreleasepool {
				let test = self.nonLeakingTest(with: selector)
				test.injectedWaiterTestCase = leaksTestCase
				test.invokeTest()
				test.injectedWaiterTestCase = nil
			}
		}
		
		for _ in 0 ..< config.preheatCount {
			performTest()
		}
		let allocationTrackerManager = FBAllocationTrackerManager.shared()!
		allocationTrackerManager.startTrackingAllocations()
		for _ in 0 ..< config.randomCount {
			performTest()
		}
		let allocationSummary = allocationTrackerManager.currentAllocationSummary()
		allocationTrackerManager.stopTrackingAllocations()
		for i in allocationSummary ?? [] where i.aliveObjects >= 0 {
			if config.excludeSystemClasses {
				let cls: AnyClass = NSClassFromString(i.className)!
				let bundle = Bundle(for: cls)
				let bundlePath = bundle.bundlePath
				if bundlePath.hasPrefix("/System/") || bundlePath.hasPrefix("/Applications/") || bundlePath.hasPrefix("/Library/"){
					continue
				}
			}
			config.reportLeak(self, selector, i, config)
		}
		(self as? LeaksSanityTesting.Type)?.didTestLeaks(for: selector, config: config)
	}
}
