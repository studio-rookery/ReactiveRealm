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
@testable import ReactiveRealm

final class CollectionChangeObservableTests: XCTestCase {
    
    func testChangesSendInitialValueSynchronously() {
        let stub = StubObservable()
        let changes = stub.reactive.changes
        var initialValue: StubObservable?
        
        changes.startWithResult { result in
            initialValue = result.value
        }
        
        XCTAssertEqual(initialValue?.id, stub.id)
    }
    
    func testChangesSendValueWhenUpdated() {
        let stub = StubObservable()
        let changes = stub.reactive.changes
        
        let exp = expectation(description: #function)
        
        var updatedStub: StubObservable?
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
        let stub = StubObservable()
        let changes = stub.reactive.changes
        
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
        
        XCTAssert(error?.error is TestError)
    }
    
    func testPropertyIgnoreError() {
        let stub = StubObservable()
        let property = stub.reactive.property
        
        let disposable = property.producer.start()
        
        stub.sendError()
        
        XCTAssertFalse(disposable.isDisposed)
    }
    
    func testInvalidate() {
        let stub = StubObservable()
        let disposable = stub.reactive.changes.start()
        
        XCTAssertEqual(stub.token.isInvalidated, false)
        
        disposable.dispose()
        XCTAssertEqual(stub.token.isInvalidated, true)
    }
}

final private class StubObservable: CollectionChangeObservable {
    
    typealias Element = Int
    
    typealias NotificationTokenType = MockToken
    
    var id = UUID().uuidString
    
    let token = MockToken()
    
    private var block: ((RealmCollectionChange<StubObservable>) -> ())?
    
    func observe(_ block: @escaping (RealmCollectionChange<StubObservable>) -> ()) -> MockToken {
        self.block = block
        sendInitial()
        return token
    }
    
    func sendInitial() {
        block?(.initial(self))
    }
    
    func sendUpdate() {
        block?(.update(self, deletions: [], insertions: [], modifications: []))
    }
    
    func sendError() {
        block?(.error(AnyError(TestError.test)))
    }
}
