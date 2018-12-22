//
//  Sugar.swift
//  GELeaks
//
//  Created by Grigory Entin on 22/12/2018.
//

func die(file: StaticString = #file, line: UInt = #line) -> Bool {
	fatalError(file: file, line: line)
}
