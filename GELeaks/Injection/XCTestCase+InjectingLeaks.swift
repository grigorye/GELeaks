//
//  XCTestCase+LeaksInjector.swift
//  Pods
//
//  Created by Grigory Entin on 20/12/2018.
//

import JRSwizzle
import XCTest

extension XCTestCase {
	
	@objc public class func injectLeaks() {
		guard leaksEnabled else {
			return
		}
		injectDefaultTestSuite()
        injectWaitForExpectations()
	}
}

extension XCTestSuite {
	
	@objc public class func injectLeaks() {
		guard leaksEnabled else {
			return
		}
		injectForTestCaseWithName()
	}
}
