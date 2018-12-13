//
//  LeaksTests.swift
//  GELeaks
//
//  Created by Grigory Entin on 08/12/2018.
//  Copyright © 2018 Grigory Entin. All rights reserved.
//

import XCTest

class Y : NSObject {
}

class LeaksTests : XCTestCase {

    func testLeak() {
		let x = NSMutableArray()
		let y = Y()
		x.add(x)
		x.add(y)
    }
}
