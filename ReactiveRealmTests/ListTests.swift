//
//  ListTests.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/01/30.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import XCTest
import Result
import ReactiveSwift
import RealmSwift
@testable import ReactiveRealm

final class ListTests: XCTestCase {

    func testProperty() {
        let realm = Realm.inMemory()
        
        let person = Person()
        
        try! realm.write {
            realm.add(person)
        }
        
        let list = person.dogs.reactive.property
        XCTAssert(list.value.isEmpty)
        
        let dogs = [Dog(), Dog()]
        
        wait(list.signal, after: {
            try! realm.write {
                person.dogs.append(objectsIn: dogs)
            }
        })
        
        XCTAssertEqual(list.value.count, dogs.count)
        XCTAssert(list.value[0].isSameObject(as: dogs[0]))
        XCTAssert(list.value[1].isSameObject(as: dogs[1]))
        
        wait(list.signal, after: {
            try! realm.write {
                person.dogs.remove(at: 1)
            }
        })
        
        XCTAssertEqual(list.value.count, 1)
        XCTAssert(list.value[0].isSameObject(as: dogs[0]))
    }
}

extension XCTestCase {
    
    @discardableResult
    func wait<T>(_ signal: T, timeout: TimeInterval = 1, name: String = #function, after action: () -> Void) -> Result<T.Value, T.Error>? where T: SignalProducerConvertible {
        let exp = expectation(description: name)
        var result: Result<T.Value, T.Error>?
        
        signal.producer.take(first: 1).startWithResult {
            result = $0
            exp.fulfill()
        }
        
        action()
        
        waitForExpectations(timeout: timeout, handler: nil)
        
        return result
    }
}
