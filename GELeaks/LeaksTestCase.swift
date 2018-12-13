//
//  LeaksTestCase.swift
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

class LeaksTestCase : XCTestCase {
    
    func testLeaks() {
        let classes = allClasses()
        for cls in classes {
            testLeaks(for: cls)
        }
    }

    lazy var testBundle = Bundle(for: type(of: self))

    func testLeaks(for cls: AnyClass) {
        guard Bundle(for: cls) === testBundle else {
            return
        }
		guard !NSStringFromClass(cls).hasPrefix("__") else {
			return
		}
        guard let testCaseClass = cls as? XCTestCase.Type else {
            return
        }
        guard testCaseClass != type(of: self) else {
            return
        }
        
        let methods = allMethods(for: cls)
        for method in methods {
            testLeaks(for: testCaseClass, method: method)
        }
    }
    
    func testLeaks(for cls: XCTestCase.Type, method: Method) {
        let selector = method_getName(method)
        let methodName = NSStringFromSelector(selector)
        guard methodName.hasPrefix("test"), !methodName.hasSuffix(":") else {
            return
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
                    let c = cls.init(selector: selector)
                    c.invokeTest()
                }
            }
        })
        if let exception = exception {
            print("\(cls).\(methodName): Caught \(exception).")
        }
    }
}

func allClasses() -> [AnyClass] {
    let estimatedNumClasses = objc_getClassList(nil, 0)
    
    guard estimatedNumClasses > 0 else {
        return []
    }
    
    let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(estimatedNumClasses))
    defer {
        allClasses.deinitialize(count: Int(estimatedNumClasses))
        allClasses.deallocate()
    }
    
    let numClasses = objc_getClassList(AutoreleasingUnsafeMutablePointer(allClasses), estimatedNumClasses)
    
    return Array(UnsafeBufferPointer(start: allClasses, count: Int(numClasses)))
}

func allMethods(for cls: AnyClass) -> [Method] {
    var numMethods: UInt32 = 0
    guard let allMethods = class_copyMethodList(cls, &numMethods) else {
        assertionFailure()
        return []
    }
    defer {
        free(allMethods)
    }
    return Array(UnsafeBufferPointer(start: allMethods, count: Int(numMethods)))
}
