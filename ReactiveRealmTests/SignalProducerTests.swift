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

    func testIgnoreError() {
        let events: [Signal<Int, NSError>.Event] = [.value(0), .failed(.dummy), .value(100)]
        let producer = SignalProducer(events).flatMap(.latest) { SignalProducer(value: $0).dematerialize().ignoreError() }
        
        let value = producer.collect().first()?.value
        XCTAssertEqual(value, [0, 100])
    }
    
    func testMapError() {
        let value = SignalProducer<Int, NSError>(error: .dummy).mapError(to: 100).first()!.value!
        XCTAssertEqual(value, 100)
    }
}
