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
    
    func testSendInitialValueSynchronously() {
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
    
    func testSendValueWhenUpdated() {
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
