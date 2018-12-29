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
			leakAsNecessary()
			it("leaks") {
				expect(true).to(be(true))
			}
		}
	}
}
