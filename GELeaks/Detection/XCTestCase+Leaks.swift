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
				if isSystemClass(cls) {
					continue
				}
			}
			config.reportLeak(self, selector, i, config)
		}
		(self as? LeaksSanityTesting.Type)?.didTestLeaks(for: selector, config: config)
	}
}

func isSystemClass(_ cls: AnyClass) -> Bool {
	
	let systemPathPrefixes: [String] = [
		"/System/",
		"/Applications/",
		"/Library/",
		"/usr/"
	]
	
	let bundle = Bundle(for: cls)
	let bundlePath = bundle.bundlePath
	
	guard systemPathPrefixes.contains(where: { bundlePath.hasPrefix($0) }) == false else {
		return true
	}
	return false
}
