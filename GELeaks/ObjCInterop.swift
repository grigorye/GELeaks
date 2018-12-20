//
//  ObjCInterop.swift
//  GELeaks
//
//  Created by Grigory Entin on 19/12/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import Foundation

extension Bundle {
	
	func allClassNames() -> [String] {
		let classNames: [String] = executablePath!.withCString { (bundlePathC) in
			var classCount: UInt32 = 0
			guard let cClassNames = objc_copyClassNamesForImage(bundlePathC, &classCount) else {
				fatalError()
			}
			defer {
				free(cClassNames)
			}
			let classNames = (0 ..< classCount).map {
				String(cString: cClassNames[Int($0)])
			}
			return classNames
		}
		return classNames
	}
	
	func allClasses() -> [AnyClass] {
		return allClassNames().map { NSClassFromString($0)! }
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
