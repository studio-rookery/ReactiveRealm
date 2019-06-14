//
//  CollectionChangeObservableTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import RealmSwift
import ReactiveSwift
@testable import ReactiveRealm

final class CollectionChangeObservableTests: XCTestCase {
    
    func testProducerSendInitialValueSynchronously() {
        let collection = MockObservableCollection()
        let changes = collection.reactive.producer
        var initialValue: MockObservableCollection?
        
        changes.startWithResult { result in
            initialValue = result.value
        }
        
        XCTAssertEqual(initialValue?.id, collection.id)
    }
    
    func testProducerSendValueWhenUpdated() {
        let collection = MockObservableCollection()
        let changes = collection.reactive.producer
        
        let exp = expectation(description: #function)
        
        var updatedcollection: MockObservableCollection?
        changes
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                updatedcollection = result.value
                exp.fulfill()
            }
        
        collection.sendUpdate()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updatedcollection?.id, collection.id)
    }
    
    func testProducerSendError() {
        let collection = MockObservableCollection()
        let changes = collection.reactive.producer
        
        let exp = expectation(description: #function)
        
        var error: Error?
        changes
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                error = result.error
                exp.fulfill()
            }
        
        collection.sendError()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(error as NSError?, .dummy)
    }
    
    func testPropertyChangeWhenUpdated() {
        let collection = MockObservableCollection()
        let property = collection.reactive.property
        
        let exp = expectation(description: #function)
        
        var updated = false
        property
            .signal
            .observeValues { _ in
                updated = true
                exp.fulfill()
            }
        
        collection.sendUpdate()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updated, true)
    }
    
    func testPropertyIgnoreError() {
        let collection = MockObservableCollection()
        let property = collection.reactive.property
        
        let disposable = property.producer.start()
        
        collection.sendError()
        
        XCTAssertFalse(disposable.isDisposed)
    }
    
    func testInvalidate() {
        let collection = MockObservableCollection()
        let disposable = collection.reactive.producer.start()
        
        XCTAssertEqual(collection.token.isInvalidated, false)
        
        disposable.dispose()
        XCTAssertEqual(collection.token.isInvalidated, true)
    }
}
