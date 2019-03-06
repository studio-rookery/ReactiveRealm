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
        let object = StubObject()
        
        let exp = expectation(description: #function)
        
        var updatedObject: StubObject?
        
        object.reactive
            .producer
            .startWithResult { result in
                updatedObject = result.value
                exp.fulfill()
            }
        
        object.sendChange()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updatedObject?.id, object.id)
    }
    
    func testDelete() {
        let object = StubObject()
        
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
        let object = StubObject()
        
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
        let object = StubObject()
        
        XCTAssertEqual(object.isInvalidated, false)
        XCTAssertEqual(object.reactive.isInvalidated.value, object.isInvalidated)
        
        object.delete()
        
        XCTAssertEqual(object.isInvalidated, true)
        XCTAssertEqual(object.reactive.isInvalidated.value, object.isInvalidated)
    }
    
    func testProperty() {
        let object = StubObject()
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

final class StubObject: ObservableObject, ReactiveExtensionsProvider {
    
    typealias NotificationTokenType = MockToken
    
    let token = MockToken()
    
    let id = UUID().uuidString
    
    private(set) var isInvalidated = false
    
    private var block: ((ObjectChange) -> ())?
    
    func observe(_ block: @escaping (ObjectChange) -> ()) -> MockToken {
        self.block = block
        return token
    }
    
    func sendChange() {
        block?(.change([]))
    }
    
    func sendError() {
        block?(.error(.test))
    }
    
    func delete() {
        isInvalidated = true
        block?(.deleted)
    }
}
