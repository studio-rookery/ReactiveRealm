//
//  MockObservableObject.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift

@testable import ReactiveRealm

final class MockObservableObject: ReactiveRealm.ObservableObject, ReactiveExtensionsProvider {
    
    typealias NotificationTokenType = MockToken
    
    let token = MockToken()
    
    let id = UUID().uuidString
    
    private(set) var isInvalidated = false
    
    private var block: ((ObjectChange<Object>) -> ())?
    
    func observe<T>(on queue: DispatchQueue? = nil, _ block: @escaping (ObjectChange<T>) -> ()) -> MockToken where T : Object {
//        self.block = block as (ObjectChange<Object>) -> ()
        return token
    }
    
    
    func sendChange() {
//        block?(Object(), .change([]))
    }
    
    func sendError() {
        block?(.error(.dummy))
    }
    
    func delete() {
        isInvalidated = true
        block?(.deleted)
    }
}
