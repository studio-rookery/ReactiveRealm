//
//  CollectionChangeObservableTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import Result
import RealmSwift
import ReactiveSwift
@testable import ReactiveRealm

extension RealmCollectionChange: Equatable where CollectionType: Equatable {
    
    public static func == (lhs: RealmCollectionChange<CollectionType>, rhs: RealmCollectionChange<CollectionType>) -> Bool {
        switch (lhs, rhs) {
        case (.initial(let left), .initial(let right)):
            return left == right
        case (.update(let left), .update(let right)):
            return left == right
        case (.error(let left), .error(let right)):
            return left == right
        default:
            return false
        }
    }
}

final class CollectionChangeObservableTests: XCTestCase {
    
    func testChangesSendInitialValueSynchronously() {
        let stub = MockObservableCollection()
        let changes = stub.reactive.producer
        var initialValue: MockObservableCollection?
        
        changes.startWithResult { result in
            initialValue = result.value
        }
        
        XCTAssertEqual(initialValue?.id, stub.id)
    }
    
    func testChangesSendValueWhenUpdated() {
        let stub = MockObservableCollection()
        let changes = stub.reactive.producer
        
        let exp = expectation(description: #function)
        
        var updatedStub: MockObservableCollection?
        changes
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                updatedStub = result.value
                exp.fulfill()
        }
        
        stub.sendUpdate()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updatedStub?.id, stub.id)
    }
    
    func testChangesSendError() {
        let stub = MockObservableCollection()
        let changes = stub.reactive.producer
        
        let exp = expectation(description: #function)
        
        var error: AnyError?
        changes
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                error = result.error
                exp.fulfill()
            }
        
        stub.sendError()
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(error?.error as NSError?, .test)
    }
    
    func testPropertyIgnoreError() {
        let stub = MockObservableCollection()
        let property = stub.reactive.property
        
        let disposable = property.producer.start()
        
        stub.sendError()
        
        XCTAssertFalse(disposable.isDisposed)
    }
    
    func testInvalidate() {
        let stub = MockObservableCollection()
        let disposable = stub.reactive.producer.start()
        
        XCTAssertEqual(stub.token.isInvalidated, false)
        
        disposable.dispose()
        XCTAssertEqual(stub.token.isInvalidated, true)
    }
}
