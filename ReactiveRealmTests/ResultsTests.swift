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
        
        let disposable = results.reactive.producer.start()
        
        results = nil
        XCTAssertNotNil(weakResults)
        
        disposable.dispose()
        XCTAssertNil(weakResults)
    }
}

// MARK: - Producer

extension ResultsTests {
    
    func testProducerSendInitialValueSynchronously() {
        let person = Person()
        
        let realm = Realm.inMemory()
        realm.forceAdd(person)
        
        let producer = realm.objects(Person.self).reactive.producer
        var initialValue: Results<Person>?
        
        producer.startWithResult { result in
            initialValue = result.value
        }
        
        XCTAssert(initialValue!.first!.isSameObject(as: person))
    }
    
    func testProducerSendValueWhenUpdated() {
        let person = Person()
        let realm = Realm.inMemory()
        let producer = realm.objects(Person.self).reactive.producer
        
        let exp = expectation(description: #function)
        
        var results: Results<Person>?
        producer
            .skip(first: 1) // ignore initial value
            .startWithResult { result in
                results = result.value
                exp.fulfill()
            }
        
        realm.forceAdd(person)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(results!.first!.isSameObject(as: person))
    }
}

// MARK: - Property

extension ResultsTests {
    
    func testPropertyInitialValue() {
        let person = Person()
        
        let realm = Realm.inMemory()
        realm.forceAdd(person)
        
        let property = realm.objects(Person.self).reactive.property
        XCTAssert(property.value.first!.isSameObject(as: person))
    }
    
    func testPropertySendValueWhenUpdated() {
        let person = Person()
        let realm = Realm.inMemory()
        let property = realm.objects(Person.self).reactive.property
        
        let exp = expectation(description: #function)
        
        var results: Results<Person>!
        property
            .producer
            .skip(first: 1) // ignore initial value
            .startWithValues {
                results = $0
                exp.fulfill()
            }
        
        realm.forceAdd(person)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(results.first!.isSameObject(as: person))
    }
    
    func testFirstInitialValue() {
        let defaultPerson = Person()
        let realm = Realm.inMemory()
        
        let first = realm.objects(Person.self).reactive.first(or: defaultPerson)
        
        XCTAssert(first.value.isSameObject(as: defaultPerson))
    }
    
    func testFirstChangedWhenUpdated() {
        let realm = Realm.inMemory()
        
        let first = realm.objects(Person.self).reactive.first()
        
        let exp = expectation(description: #function)
        
        let newPerson = Person()
        
        var updated: Person!
        first.signal.observeValues {
            updated = $0
            exp.fulfill()
        }
        
        realm.forceAdd(newPerson)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(updated.isSameObject(as: newPerson))
    }
}
