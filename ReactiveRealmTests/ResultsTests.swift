//
//  ResultsTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import RealmSwift
import ReactiveSwift
@testable import ReactiveRealm

final class ResultsTests: XCTestCase {
    
    func testRetainResultsWhileObservation() {
        let realm = Realm.inMemory()
        var results: Results<Person>! = realm.objects(Person.self)
        weak var weakResults: Results<Person>? = results
        
        let disposable = results.reactive.changes.start()
        
        results = nil
        XCTAssertNotNil(weakResults)
        
        disposable.dispose()
        XCTAssertNil(weakResults)
    }
}

// MARK: - Changes

extension ResultsTests {
    
    func testChangesSendInitialValueSynchronously() {
        let person = Person()
        
        let realm = Realm.inMemory()
        try! realm.write {
            realm.add(person)
        }
        
        let changes = realm.objects(Person.self).reactive.changes
        var initialValue: Results<Person>?
        
        changes.startWithResult { result in
            initialValue = result.value
        }
        
        XCTAssert(initialValue!.first!.isSameObject(as: person))
    }
    
    func testChangesSendValueWhenUpdated() {
        let person = Person()
        let realm = Realm.inMemory()
        let changes = realm.objects(Person.self).reactive.changes
        
        let exp = expectation(description: #function)
        
        var results: Results<Person>?
        changes
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                results = result.value
                exp.fulfill()
            }
        
        try! realm.write {
            realm.add(person)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(results!.first!.isSameObject(as: person))
    }
}

// MARK: - Property

extension ResultsTests {
    
    func testPropertyInitialValue() {
        let person = Person()
        
        let realm = Realm.inMemory()
        try! realm.write {
            realm.add(person)
        }
        
        let property = realm.objects(Person.self).reactive.property
        XCTAssert(property.value.first!.isSameObject(as: person))
    }
    
    func testPropertySendValueWhenUpdated() {
        let person = Person()
        let realm = Realm.inMemory()
        let property = realm.objects(Person.self).reactive.property
        
        let exp = expectation(description: #function)
        
        var results: Results<Person>?
        property
            .producer
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                results = result.value
                exp.fulfill()
            }
        
        try! realm.write {
            realm.add(person)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(results!.first!.isSameObject(as: person))
    }
}
