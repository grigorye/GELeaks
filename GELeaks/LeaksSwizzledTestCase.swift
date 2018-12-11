//
//  LeaksSwizzledTestCase.swift
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import FBAllocationTracker
import XCTest
import MachO

extension XCTestCase {
    
    func testLeaks(preheatCount: Int = 2, randomCount: Int = 3, _ invokeTest: () -> Void) {
        for _ in 0..<preheatCount {
            invokeTest()
        }
        let allocationTrackerManager = FBAllocationTrackerManager.shared()!
        allocationTrackerManager.startTrackingAllocations()
        for _ in 0..<randomCount {
            invokeTest()
        }
        let allocationSummary = allocationTrackerManager.currentAllocationSummary()
        allocationTrackerManager.stopTrackingAllocations()
        for i in allocationSummary ?? [] {
            guard let cls = NSClassFromString(i.className) else {
                assertionFailure()
                continue
            }
            let bundle = Bundle(for: cls)
            let bundlePath = bundle.bundlePath
            if bundlePath.hasPrefix("/System/") || bundlePath.hasPrefix("/Applications/") || bundlePath.hasPrefix("/Library/"){
                continue
            }
            guard i.aliveObjects >= 0 else {
                return
            }
            if i.aliveObjects % randomCount == 0 {
                let times = i.aliveObjects / randomCount
                XCTFail("\(cls) is likely leaked \(times) times.")
            } else {
                XCTFail("\(cls) is potentially leaked.")
            }
        }
    }
    
    @objc func swizzledInvokeTest() {
        let invokeTest = {
            self.swizzledInvokeTest()
        }
		testLeaks(preheatCount: 2, randomCount: 13, invokeTest)
    }

    @objc class func swizzleInvokeTest() {
        let oldMethod = class_getInstanceMethod(self, #selector(invokeTest))!
        let newMethod = class_getInstanceMethod(self, #selector(swizzledInvokeTest))!
        method_exchangeImplementations(oldMethod, newMethod)
    }
}

class LeaksTestCase: XCTestCase {
	
	func testLeaks() {
		var numClasses: Int32 = 0
		var allClasses: AutoreleasingUnsafeMutablePointer<AnyClass>? = nil
		defer {
			allClasses = nil
		}
		
		numClasses = objc_getClassList(nil, 0)
		
		if numClasses > 0 {
			var ptr = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(numClasses))
			defer {
				ptr.deinitialize(count: Int(numClasses))
			}
			allClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(ptr)
			numClasses = objc_getClassList(allClasses, numClasses)
			
			for i in 0 ..< numClasses {
				guard let cls: AnyClass = allClasses?[Int(i)] else {
					continue
				}
				guard Bundle(for: cls) === Bundle(for: type(of: self)) else {
					continue
				}
				guard let testCaseClass = cls as? XCTestCase.Type else {
					continue
				}
				guard cls != type(of: self) else {
					continue
				}
				
				var numMethods: UInt32 = 0
				guard let allMethods = class_copyMethodList(cls, &numMethods) else {
					assertionFailure()
					continue
				}

				for j in 0..<Int(numMethods) {
					let method = allMethods[j]
					let selector = method_getName(method)
					let methodName = NSStringFromSelector(selector)
					guard methodName.hasPrefix("test") else {
						continue
					}
					guard !methodName.hasSuffix(":") else {
						continue
					}

					testLeaks() {
						autoreleasepool {
							let c = testCaseClass.init(selector: selector)
							c.invokeTest()
						}
					}
				}
			}
		}
	}
}
