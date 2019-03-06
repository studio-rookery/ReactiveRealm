//
//  MockObservableCollection.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import Result
import RealmSwift

@testable import ReactiveRealm

final class MockObservableCollection: ObeservableCollection, Equatable {
    
    typealias Element = Int
    
    typealias NotificationTokenType = MockToken
    
    var id = UUID().uuidString
    
    let token = MockToken()
    
    private var block: ((RealmCollectionChange<MockObservableCollection>) -> ())?
    
    func observe(_ block: @escaping (RealmCollectionChange<MockObservableCollection>) -> ()) -> MockToken {
        self.block = block
        sendInitial()
        return token
    }
    
    func sendInitial() {
        block?(.initial(self))
    }
    
    func sendUpdate() {
        block?(.update(self, deletions: [], insertions: [], modifications: []))
    }
    
    func sendError() {
        block?(.error(AnyError(NSError.test)))
    }
    
    static func == (lhs: MockObservableCollection, rhs: MockObservableCollection) -> Bool {
        return lhs.id == rhs.id
    }
}
