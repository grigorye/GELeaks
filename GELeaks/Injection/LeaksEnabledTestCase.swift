//
//  LeaksEnabledTestCase.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

import XCTest

extension XCTestCase {
	
	class func leaksEnabledDefaultTestSuite() -> XCTestSuite {
		let config = LeakDetectionConfig()
		let suite = XCTestSuite(forTestCaseClass: self)
		let testCaseClass = self
		let className = NSStringFromClass(testCaseClass)
		let classPairName = className + "Leaks"
		
		classPairName.withCString { cClassPairName in
			let classPair = objc_allocateClassPair(XCTestCase.self, cClassPairName, 0) as! XCTestCase.Type
			
			for method in allMethods(for: testCaseClass) where shouldTestLeaks(for: testCaseClass, method: method) {
				addLeaksWrappedMethod(for: method, testCaseClass: testCaseClass, classPair: classPair, config: config)
			}
			
			objc_registerClassPair(classPair)
			suite.addTest(XCTestSuite(forTestCaseClass: classPair))
		}
		
		return suite
	}
}

func addLeaksWrappedMethod(for method: Method, testCaseClass: XCTestCase.Type, classPair: XCTestCase.Type, config: LeakDetectionConfig) {
	let impBlock: @convention(block) (AnyObject, Selector) -> Void = { (_self, _cmd) in
		testCaseClass.testLeaks(for: method, config: config)
	}
	let selector = method_getName(method)
	let imp = imp_implementationWithBlock(impBlock)
	let types = method_getTypeEncoding(method)
	_ = class_addMethod(classPair, selector, imp, types) || die()
}
