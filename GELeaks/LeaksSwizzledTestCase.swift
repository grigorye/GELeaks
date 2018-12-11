//
//  LeaksSwizzledTestCase.swift
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import FBAllocationTracker
import XCTest

extension XCTestCase {
    
    func testLeaks(preheatCount: Int = 2, randomCount: Int = 3, reportLeak: (FBAllocationTrackerSummary, _ randomCount: Int) -> Void, _ invokeTest: () -> Void) {
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
            reportLeak(i, randomCount)
        }
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
					guard methodName.hasPrefix("test"), !methodName.hasSuffix(":") else {
						continue
					}

                    let reportLeak = { (i: FBAllocationTrackerSummary, randomCount: Int) in
                        let leakedCls: AnyClass = NSClassFromString(i.className)!
                        if i.aliveObjects % randomCount == 0 {
                            let times = i.aliveObjects / randomCount
                            print("\(cls).\(methodName): \(leakedCls) is likely leaked \(times) times.")
                        } else {
                            print("\(cls).\(methodName): \(leakedCls) is potentially leaked.")
                        }
                    }
                    let exception = NSException.catch({
                        self.testLeaks(reportLeak: reportLeak) {
                            autoreleasepool {
                                let c = testCaseClass.init(selector: selector)
                                c.invokeTest()
                            }
                        }
                    })
                    if let exception = exception {
                        print("\(cls).\(methodName): Caught \(exception).")
                    }
				}
			}
		}
	}
}
