//
//  ListTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/30.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import ReactiveSwift
import RealmSwift
@testable import ReactiveRealm

final class ListTests: XCTestCase {

    func testProducerSendInitialValueSynchronously() {
        let realm = Realm.inMemory()
        
        let person = Person()
        let dogs = [Dog(), Dog()]
        person.dogs.append(objectsIn: dogs)
        realm.forceAdd(person)
        
        var initialValue: [Dog] = []
        person.dogs.reactive.producer.startWithResult {
            initialValue = Array($0.value!)
        }
        
        XCTAssertEqual(initialValue.count, dogs.count)
        XCTAssert(initialValue[0].isSameObject(as: dogs[0]))
        XCTAssert(initialValue[1].isSameObject(as: dogs[1]))
    }
    
    func testProducerSendValueWhenUpdated() {
        let realm = Realm.inMemory()
        
        let person = Person()
        realm.forceAdd(person)
        
        let exp = expectation(description: #function)
        
        var initialValue: [Dog] = []
        person.dogs.reactive.producer.skip(first: 1).startWithResult {
            initialValue = Array($0.value!)
            exp.fulfill()
        }
        
        let dogs = [Dog(), Dog()]
        realm.forceWrite {
            person.dogs.append(objectsIn: dogs)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(initialValue.count, dogs.count)
        XCTAssert(initialValue[0].isSameObject(as: dogs[0]))
        XCTAssert(initialValue[1].isSameObject(as: dogs[1]))
    }
    
    func testPropertyInitialValue() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        let dogs = [Dog(), Dog()]
        person.dogs.append(objectsIn: dogs)
        
        realm.forceAdd(person)
        
        let property = person.dogs.reactive.property
        
        XCTAssertEqual(property.value.count, dogs.count)
        XCTAssert(property.value[0].isSameObject(as: dogs[0]))
        XCTAssert(property.value[1].isSameObject(as: dogs[1]))
    }
    
    func testPropertyChangeWhenUpdated() {
        let realm = Realm.inMemory()
        
        let person = Person()
        realm.forceAdd(person)
        
        let property = person.dogs.reactive.property
        
        XCTAssertEqual(property.value.isEmpty, true)
        
        let exp = expectation(description: #function)
        
        var updated = false
        property.signal.observeValues { _ in
            exp.fulfill()
            updated = true
        }
        
        let dogs = [Dog(), Dog()]
        realm.forceWrite {
            person.dogs.append(objectsIn: dogs)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updated, true)
        XCTAssertEqual(property.value.count, dogs.count)
        XCTAssert(property.value[0].isSameObject(as: dogs[0]))
        XCTAssert(property.value[1].isSameObject(as: dogs[1]))
    }
    
    func testFirstInitialValue() {
        let realm = Realm.inMemory()
        
        let person = Person()
        realm.forceAdd(person)
        
        let defaultDog = Dog()
        
        let first = person.dogs.reactive.first(or: defaultDog)
        
        XCTAssert(first.value.isSameObject(as: defaultDog))
    }
    
    func testFirstChangeWhenUpdated() {
        let realm = Realm.inMemory()
        
        let person = Person()
        realm.forceAdd(person)
        
        let first = person.dogs.reactive.first()
        
        let exp = expectation(description: #function)
        
        var newFirst: Dog!
        first.signal.observeValues {
            newFirst = $0
            exp.fulfill()
        }
                
        let dog = Dog()
        realm.forceWrite {
            person.dogs.append(dog)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(newFirst.isSameObject(as: dog))
    }
}
