//
//  ObjectObservableTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import Result
import ReactiveSwift
import RealmSwift
@testable import ReactiveRealm

final class ObjectObservableTests: XCTestCase {
    
    func testChangesSendValueWhenUpdated() {
        let object = MockObservableObject()
        
        let exp = expectation(description: #function)
        
        var updated = false
        
        object.reactive
            .producer
            .startWithResult { _ in
                updated = true
                exp.fulfill()
            }
        
        object.sendChange()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(updated)
    }
    
    func testDelete() {
        let object = MockObservableObject()
        
        let exp = expectation(description: #function)
        
        var error: RealmObjectError?
        object.reactive
            .producer
            .startWithFailed {
                error = $0
                exp.fulfill()
        }
        
        object.delete()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch error {
        case .deleted?:
            XCTAssert(true)
        default:
            XCTFail()
        }
    }
    
    func testError() {
        let object = MockObservableObject()
        
        let exp = expectation(description: #function)
        
        var error: RealmObjectError?
        object.reactive
            .producer
            .startWithFailed {
                error = $0
                exp.fulfill()
            }
        
        object.sendError()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch error {
        case .unknown(let error as NSError)?:
            XCTAssertEqual(error, .test)
        default:
            XCTFail()
        }
    }
    
    func testInitialInvalidatedValue() {
        let object = MockObservableObject()
        
        XCTAssertEqual(object.isInvalidated, false)
        XCTAssertEqual(object.reactive.isInvalidated.value, false)
        
        object.delete()
        
        XCTAssertEqual(object.isInvalidated, true)
        XCTAssertEqual(object.reactive.isInvalidated.value, true)
    }
    
    func testProperty() {
        let object = MockObservableObject()
        let property = object.reactive.property
        
        XCTAssertEqual(property.value.id, object.id)
        
        let exp = expectation(description: #function)
        
        var changed = false
        property.signal.observeValues { _ in
            changed = true
            exp.fulfill()
        }
        
        object.sendChange()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(changed, true)
    }
}
