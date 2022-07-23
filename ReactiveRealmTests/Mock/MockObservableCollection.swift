//
//  MockObservableCollection.swift
//  ReactiveRealmTests
//
//  Created by hirano masaki on 2019/03/06.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import RealmSwift
import Combine

@testable import ReactiveRealm

final class MockObservableCollection: ObeservableCollection, Equatable {
    
    typealias CollectionPublisher = AnyPublisher<MockObservableCollection, Error>
    
    var id = UUID().uuidString
    
    private let subject = PassthroughSubject<MockObservableCollection, Error>()
    
    var collectionPublisher: CollectionPublisher {
        subject
            .prepend(self)
            .eraseToAnyPublisher()
    }
    
    func sendUpdate() {
        subject.send(self)
    }
    
    func sendError() {
        subject.send(completion: .failure(NSError.dummy))
    }
    
    static func == (lhs: MockObservableCollection, rhs: MockObservableCollection) -> Bool {
        return lhs.id == rhs.id
    }
}
