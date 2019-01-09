//
//  CollectionChangeObservable.swift
//  ReactiveRealm
//
//  Created by hirano masaki on 2019/01/09.
//  Copyright © 2019 ReactiveRealm. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
import RealmSwift

public protocol CollectionChangeObservable: ReactiveExtensionsProvider {
    
    associatedtype NotificationTokenType: NotificationTokenProtocol
    
    func observe(_ block: @escaping (RealmCollectionChange<Self>) -> ()) -> NotificationTokenType
}

extension Results: CollectionChangeObservable {
    
}

extension List: CollectionChangeObservable {
    
}

extension AnyRealmCollection: CollectionChangeObservable {
    
}

extension LinkingObjects: CollectionChangeObservable {
    
}

// MARK: -

public extension Reactive where Base: CollectionChangeObservable {
    
    var changes: SignalProducer<Base, AnyError> {
        return SignalProducer<Base, AnyError> { observer, lifetime in
            
            observer.send(value: self.base)
            
            let token = self.base.observe { change in
                switch change {
                case .initial:
                    break
                case .update(let collection, _, _, _):
                    observer.send(value: collection)
                case .error(let error):
                    observer.send(error: AnyError(error))
                }
            }
            
            lifetime.observeEnded {
                token.invalidate()
            }
        }
    }
    
    var property: ReactiveSwift.Property<Base> {
        return Property(initial: base, then: changes.ignoreError())
    }
}
