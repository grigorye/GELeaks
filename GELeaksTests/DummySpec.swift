//
//  DummySpec.swift
//  Pods
//
//  Created by Grigorii Entin on 12/29/18.
//

import Quick
import Nimble

class DummySpec : QuickSpec {
	override func spec() {
		describe("leak") {
			it("leaks") {
				leakAsNecessary()
				expect(true).to(be(true))
			}
		}
	}
}
