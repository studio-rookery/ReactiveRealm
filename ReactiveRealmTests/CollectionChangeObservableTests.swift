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
    
    func testChangeset() {
        let stub = StubObservable()
        let changest = stub.reactive.changeset
        
        var events: [Signal<RealmCollectionChange<StubObservable>, NoError>.Event] = []
        changest.start {
            events.append($0)
        }
        
        stub.sendUpdate()
        stub.sendError()
        
        XCTAssertEqual(events, [
            .value(.initial(stub)),
            .value(.update(stub, deletions: [], insertions: [], modifications: [])),
            .value(.error(AnyError(NSError.test)))
        ])
    }
    
    func testChangesSendInitialValueSynchronously() {
        let stub = StubObservable()
        let changes = stub.reactive.producer
        var initialValue: StubObservable?
        
        changes.startWithResult { result in
            initialValue = result.value
        }
        
        XCTAssertEqual(initialValue?.id, stub.id)
    }
    
    func testChangesSendValueWhenUpdated() {
        let stub = StubObservable()
        let changes = stub.reactive.producer
        
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
        let stub = StubObservable()
        let property = stub.reactive.property
        
        let disposable = property.producer.start()
        
        stub.sendError()
        
        XCTAssertFalse(disposable.isDisposed)
    }
    
    func testInvalidate() {
        let stub = StubObservable()
        let disposable = stub.reactive.producer.start()
        
        XCTAssertEqual(stub.token.isInvalidated, false)
        
        disposable.dispose()
        XCTAssertEqual(stub.token.isInvalidated, true)
    }
}

final private class StubObservable: CollectionChangeObservable, Equatable {
    
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
        block?(.error(AnyError(NSError.test)))
    }
    
    static func == (lhs: StubObservable, rhs: StubObservable) -> Bool {
        return lhs.id == rhs.id
    }
}
