//
//  ObjectTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/31.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import Result
import ReactiveSwift
import RealmSwift
@testable import ReactiveRealm

final class ObjectTests: XCTestCase {

    func testObjectChange() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        try! realm.write {
            realm.add(person)
        }
        
        let objectChange = person.reactive.objectChange
        
        let exp = expectation(description: #function)
        
        var results: [Signal<[PropertyChange], RealmObjectError>.Event]!
        objectChange.materialize().collect().startWithValues {
            results = $0
            exp.fulfill()
        }
        
        try! realm.write {
            person.name = "test"
        }
        
        try! realm.write {
            realm.delete(person)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(results?.count, 2)
        
        let propertyChanges = results[0].value!
        XCTAssertEqual(propertyChanges[0].name, "name")
        XCTAssertEqual(propertyChanges[0].newValue as? String, "test")
        
        let error = results[1].error!
        
        switch error {
        case .deleted:
            break
        default:
            XCTFail()
        }
    }
    
    func testIsInvalidated() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        try! realm.write {
            realm.add(person)
        }
        
        let isInvalidated = person.reactive.isInvalidated
        
        XCTAssertEqual(isInvalidated.value, false)
        
        let exp = expectation(description: #function)
        
        var isInvalidatedChanged = false
        isInvalidated.signal.observeValues { _ in
            isInvalidatedChanged = true
            exp.fulfill()
        }
        
        try! realm.write {
            realm.delete(person)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(isInvalidatedChanged, true)
    }
    
    func testIsInvalidatedInitialValue() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        try! realm.write {
            realm.add(person)
        }
        
        try! realm.write {
            realm.delete(person)
        }
        
        XCTAssertEqual(person.reactive.isInvalidated.value, true)
    }
}
