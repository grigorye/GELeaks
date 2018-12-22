//
//  Defaults.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

extension LeakDetectionConfig {
	static let defaultPreheatCount: Int = defaults.integer(forKey: "GELeaksPreheatCount") ?? 2
	static let defaultRandomCount: Int = defaults.integer(forKey: "GELeaksRandomCount") ?? 3
	static let defaultExcludeSystemClasses: Bool = defaults.bool(forKey: "GELeaksExcludeSystemClasses") ?? true
}

private let defaults = UserDefaults.standard
