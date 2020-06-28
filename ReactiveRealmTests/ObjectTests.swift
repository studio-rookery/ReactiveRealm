//
//  ObjectTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/31.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import ReactiveSwift
import RealmSwift
@testable import ReactiveRealm

final class ObjectTests: XCTestCase {

    func testRetainObjectWhileObservation() {
        let realm = Realm.inMemory()
        
        var person: Person? = Person()
        realm.forceAdd(person!)
        
        let disposable = person!.reactive.propertyChanges.start()
        
        weak var weakPerson: Person? = person
        person = nil
        
        XCTAssertNotNil(weakPerson)
        
        disposable.dispose()
        XCTAssertNil(weakPerson)
    }
    
    func testPropertyChangesSendValue() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        realm.forceAdd(person)
        
        let propertyChanges = person.reactive.propertyChanges
        
        let exp = expectation(description: #function)
        
        var results: [PropertyChange] = []
        propertyChanges.ignoreError().startWithValues {
            results = $0.1
            exp.fulfill()
        }
        
        realm.forceWrite {
            person.name = "test"
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(results.count, 1)
        
        XCTAssertEqual(results[0].name, "name")
        XCTAssertEqual(results[0].newValue as? String, "test")
    }
    
    func testPropertyChangesSendError() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        realm.forceAdd(person)
        
        let propertyChanges = person.reactive.propertyChanges
        
        let exp = expectation(description: #function)
        
        var error: RealmObjectError!
        propertyChanges.startWithFailed {
            error = $0
            exp.fulfill()
        }
        
        realm.forceDelete(person)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        switch error! {
        case .deleted:
            break
        default:
            XCTFail()
        }
    }
    
    func testPropertyInitialValue() {
        let realm = Realm.inMemory()
        
        let name = "hoge"
        
        let person = Person()
        person.name = name
        
        realm.forceAdd(person)
        
        let property = person.reactive.property
        XCTAssert(property.value.isSameObject(as: person))
        XCTAssertEqual(property.value.name, name)
    }
    
    func testPropertySendValueWhenUpdated() {
        let realm = Realm.inMemory()
        
        let person = Person()
        realm.forceAdd(person)
        
        let property = person.reactive.property
        
        XCTAssertEqual(property.value, person)
        XCTAssert(property.value.isSameObject(as: person))
        
        let exp = expectation(description: #function)
        
        var propertyChanged = false
        property.signal.observeValues { _ in
            propertyChanged = true
            exp.fulfill()
        }
        
        realm.forceWrite {
            person.name = "test"
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(propertyChanged)
    }
    
    func testIsInvalidated() {
        let realm = Realm.inMemory()
        
        let person = Person()
        realm.forceAdd(person)
        
        let isInvalidated = person.reactive.isInvalidated
        
        XCTAssertEqual(isInvalidated.value, false)
        
        let exp = expectation(description: #function)
        
        var isInvalidatedChanged = false
        isInvalidated.signal.observeValues { _ in
            isInvalidatedChanged = true
            exp.fulfill()
        }
        
        realm.forceDelete(person)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(isInvalidatedChanged, true)
    }
    
    func testIsInvalidatedInitialValue() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        // make person invalidated
        realm.forceAdd(person)
        realm.forceDelete(person)
        
        XCTAssertEqual(person.reactive.isInvalidated.value, true)
    }
}
