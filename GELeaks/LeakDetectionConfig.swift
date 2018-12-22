//
//  LeakDetectionConfig.swift
//  Pods
//
//  Created by Grigory Entin on 22/12/2018.
//

import FBAllocationTracker
import Foundation

struct LeakDetectionConfig {
	let preheatCount: Int
	let randomCount: Int
	let excludeSystemClasses: Bool
	
	typealias ReportLeak = (_ testCaseClass: AnyClass, _ selector: Selector, _ allocationSummary: FBAllocationTrackerSummary, _ config: LeakDetectionConfig) -> Void
	
	let reportLeak: ReportLeak
	
	init(preheatCount: Int = defaultPreheatCount, randomCount: Int = defaultRandomCount, excludeSystemClasses: Bool = defaultExcludeSystemClasses, reportLeak: @escaping ReportLeak = defaultReportLeak) {
		self.preheatCount = preheatCount
		self.randomCount = randomCount
		self.excludeSystemClasses = excludeSystemClasses
		self.reportLeak = reportLeak
	}
}
