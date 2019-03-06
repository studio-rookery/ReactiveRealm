//
//  MockObservableObject.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import Result
import RealmSwift
import ReactiveSwift

@testable import ReactiveRealm

final class MockObservableObject: ObservableObject, ReactiveExtensionsProvider {
    
    typealias NotificationTokenType = MockToken
    
    let token = MockToken()
    
    let id = UUID().uuidString
    
    private(set) var isInvalidated = false
    
    private var block: ((ObjectChange) -> ())?
    
    func observe(_ block: @escaping (ObjectChange) -> ()) -> MockToken {
        self.block = block
        return token
    }
    
    func sendChange() {
        block?(.change([]))
    }
    
    func sendError() {
        block?(.error(.test))
    }
    
    func delete() {
        isInvalidated = true
        block?(.deleted)
    }
}
