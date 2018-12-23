//
//  XCTestCase+LeaksInjector.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import XCTest

extension XCTestCase {
	
	@objc public class func injectLeaks() {
		guard leaksEnabled else {
			return
		}
		injectDefaultTestSuite()
	}
	
	private class func injectDefaultTestSuite() {
		let oldMethod = class_getClassMethod(self, #selector(getter: defaultTestSuite))!
		let newMethod = class_getClassMethod(self, #selector(leaksEnabledDefaultTestSuite))!
		method_exchangeImplementations(oldMethod, newMethod)
	}
}
