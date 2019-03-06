//
//  LinkingObjectsTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import Foundation
import Result
import ReactiveSwift
import RealmSwift
@testable import ReactiveRealm

final class LinkingObjectsTests: XCTestCase {
    
    func testProducerSendInitialValueSynchronously() {
        let realm = Realm.inMemory()
        
        let dog = Dog()
        let persons = [Person(), Person()]
        
        persons.forEach {
            $0.dogs.append(dog)
        }
        
        realm.forceAdd(persons)
        
        var initialValue: [Person] = []
        dog.owners.reactive.producer.startWithResult {
            initialValue = Array($0.value!)
        }
        
        XCTAssertEqual(initialValue.count, persons.count)
        XCTAssert(initialValue[0].isSameObject(as: persons[0]))
        XCTAssert(initialValue[1].isSameObject(as: persons[1]))
    }
    
    func testProducerSendValueWhenUpdated() {
        let realm = Realm.inMemory()
        
        let dog = Dog()
        realm.forceAdd(dog)
        
        let exp = expectation(description: #function)
        
        var updatedValue: [Person] = []
        dog.owners.reactive.producer.skip(first: 1).startWithResult {
            updatedValue = Array($0.value!)
            exp.fulfill()
        }
        
        let persons = [Person(), Person()]
        realm.forceWrite {
            persons.forEach {
                $0.dogs.append(dog)
            }
            realm.add(persons)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updatedValue.count, persons.count)
        XCTAssert(updatedValue[0].isSameObject(as: persons[0]))
        XCTAssert(updatedValue[1].isSameObject(as: persons[1]))
    }
    
    func testPropertyInitialValue() {
        let realm = Realm.inMemory()
        
        let dog = Dog()
        let persons = [Person(), Person()]
        
        persons.forEach {
            $0.dogs.append(dog)
        }
        
        realm.forceAdd(persons)
        
        let initialValue = dog.owners.reactive.property.value
        
        XCTAssertEqual(initialValue.count, persons.count)
        XCTAssert(initialValue[0].isSameObject(as: persons[0]))
        XCTAssert(initialValue[1].isSameObject(as: persons[1]))
    }
    
    func testPropertyChangeWhenUpdated() {
        let realm = Realm.inMemory()
        
        let dog = Dog()
        realm.forceAdd(dog)
        
        let exp = expectation(description: #function)
        
        var updatedValue: [Person] = []
        dog.owners.reactive.property.signal.observeResult {
            updatedValue = Array($0.value!)
            exp.fulfill()
        }
        
        let persons = [Person(), Person()]
        realm.forceWrite {
            persons.forEach {
                $0.dogs.append(dog)
            }
            realm.add(persons)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(updatedValue.count, persons.count)
        XCTAssert(updatedValue[0].isSameObject(as: persons[0]))
        XCTAssert(updatedValue[1].isSameObject(as: persons[1]))
    }
    
    func testFirstInitialValue() {
        let realm = Realm.inMemory()
        
        let defaultPerson = Person()
        let dog = Dog()
        realm.forceAdd(dog)
        
        let first = dog.owners.reactive.first(or: defaultPerson)
        
        XCTAssert(first.value.isSameObject(as: defaultPerson))
    }
    
    func testFirstChangeWhenUpdated() {
        let realm = Realm.inMemory()
        
        let dog = Dog()
        realm.forceAdd(dog)
        
        let exp = expectation(description: #function)
        
        var newFirst: Person!
        dog.owners.reactive.first().signal.observeValues {
            newFirst = $0
            exp.fulfill()
        }
        
        let person = Person()
        
        realm.forceWrite {
            person.dogs.append(dog)
            realm.add(person)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(newFirst.isSameObject(as: person))
    }
}
