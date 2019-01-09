//
//  SignalProducerTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import ReactiveRealm

final class SignalProducerTests: XCTestCase {

    func testMapError() {
        let value = SignalProducer<Int, NSError>(error: TestError.test).mapError(to: 100).first()!.value!
        XCTAssertEqual(value, 100)
    }
}
