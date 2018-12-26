//
//  LeaksSanityTests.swift
//  GELeaks
//
//  Created by Grigorii Entin on 12/11/18.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

// A protocol for handling sanity tests like no other tests.
protocol LeaksSanityTesting : class {
	
	static var _Self: LeaksSanityReportsClassState { get }
	static func didTestLeaks(for selector: Selector, config: LeakDetectionConfig)
}
