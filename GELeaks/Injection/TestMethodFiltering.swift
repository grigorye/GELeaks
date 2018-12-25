//
//  TestMethodFiltering.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

import class XCTest.XCTestCase

func shouldTestLeaks(for testCaseClass: XCTestCase.Type, method: Method, selectedMethodName: String? = nil) -> Bool {
	let selector = method_getName(method)
	let methodName = NSStringFromSelector(selector)
	guard methodName.hasPrefix("test") && !methodName.hasSuffix(":") else {
		return false
	}
	if let selectedMethodName = selectedMethodName, methodName != selectedMethodName {
		return false
	}
	return true
}
