//
//  LeaksEnabledTestCase.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

import XCTest

private class BundleTag {}

private var injectedWaiterTestCaseAssoc: Void?

extension XCTestCase {
	
	@objc public class func leaksEnabledDefaultTestSuite() -> XCTestSuite {
		let config = LeakDetectionConfig()
		let suite = XCTestSuite(name: "Leaks enabled \(self)")
		let originalSuite = XCTestSuite(forTestCaseClass: self)
		let testCaseClass = self
		let className = NSStringFromClass(testCaseClass)
		let classPairName = className + "Leaks"
		let classPairSuiteName = classPairName
		
		let classPairSuite = originalSuite.leaksClassPairSuite(withClassPairName: classPairName, classPairSuiteName: classPairSuiteName, testCaseClass: testCaseClass, config: config)
		
		suite.addTest(originalSuite)
		suite.addTest(classPairSuite)
		
		return suite
	}
	
	@objc public var injectedWaiterTestCase: XCTestCase? {
		set {
			objc_setAssociatedObject(self, &injectedWaiterTestCaseAssoc, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
		get {
			let value = objc_getAssociatedObject(self, &injectedWaiterTestCaseAssoc) as! XCTestCase?
			return value
		}
	}
	
	@objc(leaksEnabledWaitForExpectations:timeout:)
	public func leaksEnabledWait(for expectations: [XCTestExpectation], timeout seconds: TimeInterval) {
		guard let injectedWaiterTestCase = self.injectedWaiterTestCase else {
			self.leaksEnabledWait(for: expectations, timeout: seconds)
			return
		}
		injectedWaiterTestCase.wait(for: expectations, timeout: seconds)
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
		
		guard NSClassFromString(classPairName) == nil else {
			return originalSuite
		}
		
		let suite = XCTestSuite(name: "Leaks enabled \(leaksUnawareName)")
		let classPairSuiteName = [testCaseName + "Leaks", testMethodName].compactMap { $0 }.joined(separator: "/")
		
		let classPairSuite = originalSuite.leaksClassPairSuite(withClassPairName: classPairName, classPairSuiteName: classPairSuiteName, testCaseClass: testCaseClass, config: config)
		
		suite.addTest(originalSuite)
		suite.addTest(classPairSuite)
		return suite
	}
}

func addLeaksWrappedMethod(for method: Method, testCaseClass: XCTestCase.Type, classPair: XCTestCase.Type, config: LeakDetectionConfig) {
	let impBlock: @convention(block) (XCTestCase, Selector) -> Void = { (_self, _cmd) in
		testCaseClass.testLeaks(for: method, config: config, leaksTestCase: _self)
	}
	let selector = method_getName(method)
	let imp = imp_implementationWithBlock(impBlock)
	let types = method_getTypeEncoding(method)
	_ = class_addMethod(classPair, selector, imp, types) || die()
}

extension XCTestSuite {
	
	func leaksClassPairSuite(withClassPairName classPairName: String, classPairSuiteName: String, testCaseClass: XCTestCase.Type, config: LeakDetectionConfig) -> XCTestSuite {
		
		return classPairName.withCString { cClassPairName in
			let classPair = objc_allocateClassPair(XCTestCase.self, cClassPairName, 0) as! XCTestCase.Type
			
			for method in allMethods(for: self) {
				addLeaksWrappedMethod(for: method, testCaseClass: testCaseClass, classPair: classPair, config: config)
			}
			
			objc_registerClassPair(classPair)
			
			let classPairSuite = XCTestSuite(name: classPairSuiteName)
			
			for i in self.tests {
				let selector = (i as! XCTestCase).invocation!.selector
				let test = classPair.nonLeakingTest(with: selector)
				classPairSuite.addTest(test)
			}
			
			return classPairSuite
		}
	}
}

func allMethods(for testSuite: XCTestSuite) -> [Method] {
	var methods: [Method] = []
	for test in testSuite.tests {
		if let testCase = test as? XCTestCase {
			let invocation = testCase.invocation!
			let selector = invocation.selector
			let method = class_getInstanceMethod(type(of: testCase), selector)!
			methods.append(method)
		}
	}
	return methods
}
