//
//  LeaksTestCase.swift
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import FBAllocationTracker
import XCTest

var testingLeaksSanity = false

class LeaksTestCase : XCTestCase {
	
    func testLeaksForAllTestCases() {
		let testCaseClasses = Bundle(for: type(of: self)).allClasses().compactMap { $0 as? XCTestCase.Type }
		
		var generalTestCaseClasses: [XCTestCase.Type] = []
		var sanityTestCaseClasses: [(XCTestCase & LeaksSanityTesting).Type] = []
		
		testCaseClasses.forEach {
			if let sanityTestCaseClass = $0 as? (XCTestCase & LeaksSanityTesting).Type {
				sanityTestCaseClasses.append(sanityTestCaseClass)
			} else {
				generalTestCaseClasses.append($0)
			}
		}
		
		testLeaksSanity(with: sanityTestCaseClasses)
		testLeaks(for: generalTestCaseClasses)
	}
	
	private func testLeaks(for testCaseClasses: [XCTestCase.Type]) {
		let config = LeakDetectionConfig(preheatCount: 2, randomCount: 3, reportLeak: defaultReportLeak)
		testCaseClasses.forEach { testCaseClass in
			autoreleasepool {
				testLeaks(for: testCaseClass, config: config)
			}
		}
	}
	
	private func testLeaksSanity(with sanityTestCaseClasses: [(XCTestCase & LeaksSanityTesting).Type]) {
		testingLeaksSanity = true
		defer {
			testingLeaksSanity = false
		}
		
		let config = LeakDetectionConfig(preheatCount: 2, randomCount: 3, reportLeak: { (testCaseClass, selector, allocationSummary, config) in
			let leaksSanityTests = testCaseClass as! LeaksSanityTesting.Type
			leaksSanityTests.reportLeak(selector, allocationSummary, config)
		})
		sanityTestCaseClasses.forEach { testCaseClass in
			autoreleasepool {
				testLeaks(for: testCaseClass, config: config)
			}
		}
		
		sanityTestCaseClasses.forEach {
			$0.assertSanity(for: config)
		}
	}

	private func testLeaks(for testCaseClass: XCTestCase.Type, config: LeakDetectionConfig) {
        let methods = allMethods(for: testCaseClass)
        for method in methods where shouldTestLeaks(for: testCaseClass, method: method) {
			testCaseClass.testLeaks(for: method, config: config)
        }
    }

	private func shouldTestLeaks(for testCaseClass: XCTestCase.Type, method: Method) -> Bool {
		guard testCaseClass != type(of: self) else {
			return !sel_isEqual(method_getName(method), #selector(testLeaksForAllTestCases))
		}
		return true
	}
}
