//
//  UserDefaults+OptionalValues.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

extension UserDefaults {
	
	func integer(forKey defaultName: String) -> Int? {
		guard nil != object(forKey: defaultName) else {
			return nil
		}
		return integer(forKey: defaultName)
	}
	
	func bool(forKey defaultName: String) -> Bool? {
		guard nil != object(forKey: defaultName) else {
			return nil
		}
		return bool(forKey: defaultName)
	}
}
