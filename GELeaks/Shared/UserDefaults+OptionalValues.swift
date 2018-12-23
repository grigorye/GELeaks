//
//  UserDefaults+OptionalValues.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

extension UserDefaults_Nonoptional {
	
	func integer(forKey defaultName: String) -> Int? {
		guard nil != object(forKey: defaultName) else {
			return nil
		}
		return (integer(forKey: defaultName) as Int)
	}
	
	func bool(forKey defaultName: String) -> Bool? {
		guard nil != object(forKey: defaultName) else {
			return nil
		}
		return (bool(forKey: defaultName) as Bool)
	}
}

protocol UserDefaults_Nonoptional {
	
	func object(forKey defaultName: String) -> Any?
	func integer(forKey defaultName: String) -> Int
	func bool(forKey defaultName: String) -> Bool
}

extension UserDefaults : UserDefaults_Nonoptional {}
