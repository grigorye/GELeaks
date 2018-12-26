//
//  LeaksEnabledTestCase.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

import XCTest

private class BundleTag {}

extension XCTestCase {
	
	class func leaksEnabledDefaultTestSuite() -> XCTestSuite {
		let config = LeakDetectionConfig()
		let suite = XCTestSuite(name: "Leaks enabled \(self)")
		suite.addTest(XCTestSuite(forTestCaseClass: self))
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

extension XCTestSuite {
	
	@objc(leaksEnabledTestSuiteForTestCaseWithName:)
	public class func leaksEnabledTestSuiteForTestCaseWithName(_ name: String) -> XCTestSuite {
		let nameComponents = name.split(separator: "/")
		let leaksAwareTestCaseName = String(nameComponents.first!)
		let testCaseName: String = {
			if leaksAwareTestCaseName.hasSuffix("Leaks") {
				let endIndex = leaksAwareTestCaseName.endIndex
				let i = leaksAwareTestCaseName.index(endIndex, offsetBy: -"Leaks".count)
				return String(leaksAwareTestCaseName[..<i])
			}
			return leaksAwareTestCaseName
		}()
		let testMethodName: String? = (nameComponents.count > 1) ? String(nameComponents[1]) : nil
		let testCaseClassName = Bundle(for: BundleTag.self).allClassNames().first { ($0 == testCaseName) || $0.hasSuffix("." + testCaseName) }!
		let testCaseClass = NSClassFromString(testCaseClassName) as! XCTestCase.Type
		
		let config = LeakDetectionConfig()
		let leaksUnawareName = [testCaseName, testMethodName].compactMap { $0 }.joined(separator: "/")
		let originalSuite = self.leaksEnabledTestSuiteForTestCaseWithName(leaksUnawareName)
		let className = NSStringFromClass(testCaseClass)
		let classPairName = className + "Leaks"
		
		let suite: XCTestSuite
		if NSClassFromString(classPairName) != nil {
			suite = originalSuite
		} else {
			suite = XCTestSuite(name: "Leaks enabled \(leaksUnawareName)")
			suite.addTest(originalSuite)
			classPairName.withCString { cClassPairName in
				let classPair = objc_allocateClassPair(XCTestCase.self, cClassPairName, 0) as! XCTestCase.Type
				
				for method in allMethods(for: testCaseClass) where shouldTestLeaks(for: testCaseClass, method: method, selectedMethodName: testMethodName) {
					addLeaksWrappedMethod(for: method, testCaseClass: testCaseClass, classPair: classPair, config: config)
				}
				
				objc_registerClassPair(classPair)
				suite.addTest(XCTestSuite(forTestCaseClass: classPair))
			}
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
